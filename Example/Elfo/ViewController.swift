//
//  ViewController.swift
//  Elfo
//
//  Created by douwebos on 12/12/2020.
//  Copyright (c) 2020 douwebos. All rights reserved.
//

import UIKit
import Elfo

internal extension Decodable {
    static func from(data: Data) -> Self? {
        do {
            return try JSONDecoder().decode(self, from: data)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

internal extension Data {
    func asCodable<T: Codable>(of type: T.Type) -> T? {
        return T.from(data: self)
    }
}

internal extension Dictionary where Key == String, Value == Any? {
    var asData: Data? {
        get {
            return try? JSONSerialization.data(withJSONObject: self)
        }
    }
}

struct TestEvent: ElfoPublishable {
    static var type: String = "log"
    
    static var group: String = "test"
    
    var kind: String {
        get {
            return "event"
        }
    }
    
    let index: Int
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        post(index: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func post(index: Int) {
        let rawData: [String: Any?] = [
            "index": index
        ]
        
        if let event = rawData.asData?.asCodable(of: TestEvent.self) {
            Elfo.publish(event: event)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.post(index: index + 1)
            }
        }
    }
}
