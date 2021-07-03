//
//  ElfoInjector.swift
//  Elfo
//
//  Created by Douwe Bos on 13/12/20.
//

import Foundation

protocol ElfoInjectorDelegate: class {
    func urlSessionInjector(_ injector: ElfoInjector?, didStart dataTask: URLSessionDataTask?)
    func urlSessionInjector(_ injector: ElfoInjector?, didReceiveResponse dataTask: URLSessionDataTask?, response: URLResponse?)
    func urlSessionInjector(_ injector: ElfoInjector?, didReceiveData dataTask: URLSessionDataTask?, data: Data?)
    func urlSessionInjector(_ injector: ElfoInjector?, didFinishWithError dataTask: URLSessionDataTask?, error: Error?)
}

class ElfoInjector {
    private var didInject: Bool = false
    
    private var interposeHooks: [Interpose] = []
    
    static var shared: ElfoInjector = {
        return ElfoInjector()
     }()
    
    weak var delegate: ElfoInjectorDelegate? = nil
    
    private init() {
        inject()
    }

    private func inject() {
        guard !didInject else { return }
        didInject = true
        
        Interpose.isLoggingEnabled = true
        
        if let sessionClazz = NSClassFromString("__NSCFURLLocalSessionConnection") {
            swizzleSessionConnection(sessionClazz)
        }
        
        if let taskClazz = NSClassFromString("__NSCFURLSessionTask") {
            swizzleSessionTask(taskClazz)
        }
    }
    
    private func swizzleSessionTask(_ clazz: AnyClass) {
        if let resumeHook = try? Interpose(clazz, builder: {
            try $0.prepareHook(
                NSSelectorFromString("resume"),
                methodSignature: (@convention(c) (AnyObject, Selector) -> Void).self,
                hookSignature: (@convention(block) (AnyObject) -> Void).self) {
                    store in { [weak self] task in
                        if let t = task as? URLSessionDataTask {
                            self?.delegate?.urlSessionInjector(self, didStart: t)
                        }
                        
                        store.original(task, store.selector)
                    }
            }
        }) {
            interposeHooks.append(resumeHook)
        }
    }
    
    private func swizzleSessionConnection(_ clazz: AnyClass) {
        if let didReceiveDataHook = try? Interpose(clazz, builder: {
            try $0.prepareHook(
                NSSelectorFromString("_didReceiveData:"),
                methodSignature: (@convention(c) (NSObject, Selector, AnyObject) -> Void).self,
                hookSignature: (@convention(block) (NSObject, AnyObject) -> Void).self) {
                    store in { [weak self] connection, data in
                        if let task = connection.value(forKey: "task") as? URLSessionDataTask, let d = data as? Data {
                            self?.delegate?.urlSessionInjector(self, didReceiveData: task, data: d)
                        }
                        
                        store.original(connection, store.selector, data)
                    }
            }
        }) {
            interposeHooks.append(didReceiveDataHook)
        }
        
        if let didFinishWithErrorHook = try? Interpose(clazz, builder: {
            try $0.prepareHook(
                NSSelectorFromString("_didFinishWithError:"),
                methodSignature: (@convention(c) (NSObject, Selector, NSError) -> Void).self,
                hookSignature: (@convention(block) (NSObject, NSError) -> Void).self) {
                    store in { [weak self] connection, error in
                        if let task = connection.value(forKey: "task") as? URLSessionDataTask {
                            self?.delegate?.urlSessionInjector(self, didFinishWithError: task, error: error)
                        }
                        
                        store.original(connection, store.selector, error)
                    }
            }
        }) {
            interposeHooks.append(didFinishWithErrorHook)
        }
        
        if #available(iOS 13, *) {
            if let didReceiveResponse = try? Interpose(clazz, builder: {
                try $0.prepareHook(
                    NSSelectorFromString("_didReceiveResponse:sniff:rewrite:"),
                    methodSignature: (@convention(c) (NSObject, Selector, URLResponse, Bool, Bool) -> Void).self,
                    hookSignature: (@convention(block) (NSObject, URLResponse, Bool, Bool) -> Void).self) {
                        store in { [weak self] connection, response, sniff, rewrite in
                            if let task = connection.value(forKey: "task") as? URLSessionDataTask {
                                self?.delegate?.urlSessionInjector(self, didReceiveResponse: task, response: response)
                            }
                            
                            store.original(connection, store.selector, response, sniff, rewrite)
                        }
                }
            }) {
                interposeHooks.append(didReceiveResponse)
            }
        }
        
        if let didReceiveResponse = try? Interpose(clazz, builder: {
            try $0.prepareHook(
                NSSelectorFromString("_didReceiveResponse:sniff:"),
                methodSignature: (@convention(c) (NSObject, Selector, URLResponse, Bool) -> Void).self,
                hookSignature: (@convention(block) (NSObject, URLResponse, Bool) -> Void).self) {
                    store in { [weak self] connection, response, sniff in
                        if let task = connection.value(forKey: "task") as? URLSessionDataTask {
                            self?.delegate?.urlSessionInjector(self, didReceiveResponse: task, response: response)
                        }
                        
                        store.original(connection, store.selector, response, sniff)
                    }
            }
        }) {
            interposeHooks.append(didReceiveResponse)
        }
    }
    
    private func getClassesConformingProtocol(_ p: Protocol)-> [AnyClass]{
            let expectedClassCount = objc_getClassList(nil, 0)
            let allClasses = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(expectedClassCount))
            let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
            let actualClassCount:Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)

            var classes = [AnyClass]()
            for i in 0 ..< actualClassCount {
                let currentClass: AnyClass = allClasses[Int(i)]
                if class_conformsToProtocol(currentClass, p) {
                    classes.append(currentClass)
                }
            }

            return classes

    }
}
