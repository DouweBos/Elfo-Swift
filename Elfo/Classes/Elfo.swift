//
//  Elfo.swift
//  Elfo
//
//  Created by Douwe Bos on 12/12/20.
//

import Foundation

public struct Elfo {
    public struct Configuration {
        let project: String
        let device: String
        
        let netservicePort: Int
        let netserviceType: String
        let netserviceDomain: String
        let netserviceName: String
        
        public static var defaultConfiguration: Elfo.Configuration {
            return Elfo.Configuration(
                project: ElfoUtility.projectName,
                device: ElfoUtility.deviceId,
                netservicePort: 54546,
                netserviceType: "_Elfo._tcp",
                netserviceDomain: "",
                netserviceName: ""
            )
        }
    }
    
    static var controller: ElfoController? = nil
    
    public static func start(
        configuration: Configuration = Configuration.defaultConfiguration
    ) {
        controller = ElfoController(config: configuration)
    }
}

public extension Elfo {
    static func publish(event: ElfoPublishable) {
        controller?.publish(event: event)
    }
}
