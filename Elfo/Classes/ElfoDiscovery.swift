//
//  Discovery.swift
//  Elfo
//
//  Created by Douwe Bos on 12/12/20.
//

import Foundation
import CocoaAsyncSocket

protocol ElfoDiscoveryDelegate: class {
    func didDiscover(service: NetService)
}

class ElfoDiscovery: NSObject {
    let config: Elfo.Configuration
    
    weak var delegate: ElfoDiscoveryDelegate? = nil
    
    private var service: NetServiceBrowser? = nil
    
    private var services: [NetService] = []
    
    init(config: Elfo.Configuration) {
        self.config = config
        
        super.init()
    }
    
    func start() {
        services = []
        
        service = NetServiceBrowser()
        service?.delegate = self
        service?.searchForServices(ofType: self.config.netserviceType,
                                   inDomain: self.config.netserviceDomain
        )
    }
    
    func restart() {
        service?.stop()
        service = nil
        
        start()
    }
}

extension ElfoDiscovery: NetServiceBrowserDelegate {
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        services.append(service)
        
        service.delegate = self
        service.resolve(withTimeout: 30.0)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if let index = services.firstIndex(of: service) {
            services.remove(at: index)
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        restart()
    }
}

extension ElfoDiscovery: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        delegate?.didDiscover(service: sender)
    }
}
