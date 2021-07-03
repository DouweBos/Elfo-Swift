//
//  ElfoController.swift
//  Elfo
//
//  Created by Douwe Bos on 13/12/20.
//

import Foundation
import DJBExtensionKit
#if canImport(Mixpanel)
import Mixpanel
#endif

class ElfoController: NSObject {
    let config: Elfo.Configuration
    
    let discovery: ElfoDiscovery
    let publisher: ElfoPublisher
    
    init(config: Elfo.Configuration) {
        self.config = config
        
        self.discovery = ElfoDiscovery(config: config)
        self.publisher = ElfoPublisher(config: config)
        
        super.init()
        
        ElfoInjector.shared.delegate = self
        self.publisher.delegate = self
        self.discovery.delegate = self
        self.discovery.start()
    }
}

extension ElfoController: ElfoDiscoveryDelegate {
    func didDiscover(service: NetService) {
        publisher.connectToService(service: service)
    }
}

extension ElfoController: ElfoPublisherDelegate {
    private func parse(body: Data) {
        print(body.asString)
    }
    
    func didReceive(data: Data) {
        parse(body: data)
    }
}

extension ElfoController {
    func publish(event: ElfoPublishable) {
        var json = event.asJSON()
        json["deviceId"] = config.device
        json["deviceName"] = ElfoUtility.deviceName
        json["project"] = config.project
        
        guard let data = json.asData else { return }
        
        self.publisher.publish(data: data)
    }
}

extension ElfoController: ElfoInjectorDelegate {
    func urlSessionInjector(_ injector: ElfoInjector?, didStart dataTask: URLSessionDataTask?) {
        let rawData: [String: Any?] = [
            "timestamp": Int(Date().timeIntervalSince1970),
            "url": dataTask?.originalRequest?.url?.absoluteString,
            "headers": dataTask?.originalRequest?.allHTTPHeaderFields,
            "body": dataTask?.originalRequest?.httpBody?.asString,
            "method": dataTask?.originalRequest?.httpMethod
        ]
        
        if let event = rawData.asData?.asCodable(of: ElfoURLSessionTaskDidResumeEvent.self) {
            publish(event: event)
        }
    }
    
    func urlSessionInjector(_ injector: ElfoInjector?, didReceiveResponse dataTask: URLSessionDataTask?, response: URLResponse?) {
        let rawData: [String: Any?] = [
            "timestamp": Int(Date().timeIntervalSince1970),
            "url": dataTask?.originalRequest?.url?.absoluteString,
            "headers": dataTask?.originalRequest?.allHTTPHeaderFields,
            "body": dataTask?.originalRequest?.httpBody?.asString,
            "method": dataTask?.originalRequest?.httpMethod,
            "statusCode": (response as? HTTPURLResponse)?.statusCode
        ]
        
        if let event = rawData.asData?.asCodable(of: ElfoURLSessionTaskDidReceiveResponseEvent.self) {
            publish(event: event)
        }
    }
    
    func urlSessionInjector(_ injector: ElfoInjector?, didReceiveData dataTask: URLSessionDataTask?, data: Data?) {
        
    }
    
    func urlSessionInjector(_ injector: ElfoInjector?, didFinishWithError dataTask: URLSessionDataTask?, error: Error?) {
        
    }
}
