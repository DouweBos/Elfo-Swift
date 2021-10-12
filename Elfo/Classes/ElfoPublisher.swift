//
//  ElfoPublisher.swift
//  Elfo
//
//  Created by Douwe Bos on 13/12/20.
//

import Foundation
import CocoaAsyncSocket

protocol ElfoPublisherDelegate: class {
    func didReceive(data: Data)
}

class ElfoPublisher: NSObject {
    let config: Elfo.Configuration
    
    weak var delegate: ElfoPublisherDelegate? = nil
    
    private let socketReadWriteLock = ReadWriteLock(label: "com.djbsoftware.elfo.publisher.sockets")
    private let publishQueue = DispatchQueue(label: "com.djbsoftware.elfo.publisher.queue")
    
    private var sockets: [GCDAsyncSocket] = []
    
    init(config: Elfo.Configuration) {
        self.config = config
        
        super.init()
    }
    
    func publish(data: Data?) {
        publishQueue.sync {
            socketReadWriteLock.read {
                sockets.forEach { sock in
                    sock.write(data, withTimeout: -1.0, tag: 0)
                }
            }
        }
    }
}

extension ElfoPublisher {
    @discardableResult
    func connectToService(service: NetService) -> Bool {
        var _isConnected: Bool = false
        let addresses = service.addresses ?? []
        
        guard !addresses.isEmpty else { return false }
        
        let socket = GCDAsyncSocket(
            delegate: self,
            delegateQueue: DispatchQueue.main
        )
        
        while !_isConnected {
            if let address = addresses.first {
                do {
                    try socket.connect(toAddress: address)
                    
                    socketReadWriteLock.write {
                        sockets.append(socket)
                    }
                    
                    _isConnected = true
                } catch {
                    Beaver.error(error, context: self)
                }
            }
        }
        
        return _isConnected
    }
}

extension ElfoPublisher: GCDAsyncSocketDelegate {
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        sock.delegate = nil
        
        socketReadWriteLock.write {
            self.sockets = Array(self.sockets.filter { $0 !== sock })
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let strongSelf = self else { return }
            
            let rawData: [String: Any?] = [
                "project": strongSelf.config.project,
                "deviceId": strongSelf.config.device,
                "deviceName": ElfoUtility.deviceName
            ]
            
            if let event = rawData.asData?.asCodable(of: ElfoHandshakeEvent.self) {
                Elfo.publish(event: event)
            }
        }
        
        sock.readData(
            withTimeout: -1.0,
            tag: 0
        )
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        self.delegate?.didReceive(data: data)
        
        sock.readData(
            withTimeout: -1.0,
            tag: tag
        )
    }
}
