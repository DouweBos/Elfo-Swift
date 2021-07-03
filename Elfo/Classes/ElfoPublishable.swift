//
//  ElfoPublishable.swift
//  Elfo
//
//  Created by Douwe Bos on 14/12/20.
//

import Foundation

public protocol ElfoPublishable: Codable {
    static var type: String { get }
    static var group: String { get }
    var kind: String { get }
}

extension ElfoPublishable {
    func asJSON() -> [String: Any?] {
        return [
            "type": Self.type,
            "group": Self.group,
            "kind": self.kind,
            "data": self.asData?.asJSON ?? [:]
        ]
    }
}

enum ElfoPublishableType: String {
    case handshake
    case log
}

enum ElfoPublishableGroup: String {
    case handshake
    case networkRequest
    case analytics
}

enum ElfoPublishableKind: String {
    case clientHandshake
    case urlSessionTaskDidResume
    case urlSessionDidReceiveResponse
    case mixpanelEvent
}

struct ElfoHandshakeEvent: ElfoPublishable, Codable {
    static var type: String {
        get {
            return ElfoPublishableType.handshake.rawValue
        }
    }
    
    static var group: String {
        get {
            return ElfoPublishableGroup.handshake.rawValue
        }
    }
    
    var kind: String {
        get {
            return ElfoPublishableKind.clientHandshake.rawValue
        }
    }
    
    let project: String
    let deviceId: String
    let deviceName: String
}

struct ElfoURLSessionTaskDidResumeEvent: ElfoPublishable, Codable {
    static var type: String {
        get {
            return ElfoPublishableType.log.rawValue
        }
    }
    
    static var group: String {
        get {
            return ElfoPublishableGroup.networkRequest.rawValue
        }
    }
    
    var kind: String {
        get {
            return ElfoPublishableKind.urlSessionTaskDidResume.rawValue
        }
    }
    
    let timestamp: Int
    let url: String?
    let headers: [String: String]?
    let body: String?
    let method: String?
}

struct ElfoURLSessionTaskDidReceiveResponseEvent: ElfoPublishable, Codable {
    static var type: String {
        get {
            return ElfoPublishableType.log.rawValue
        }
    }
    
    static var group: String {
        get {
            return ElfoPublishableGroup.networkRequest.rawValue
        }
    }
    
    var kind: String {
        get {
            return ElfoPublishableKind.urlSessionDidReceiveResponse.rawValue
        }
    }
    
    let timestamp: Int
    let url: String?
    let headers: [String: String]?
    let body: String?
    let method: String?
    
    let statusCode: Int?
}

#if canImport(Mixpanel)
struct ElfoMixpanelEvent: ElfoPublishable {
    static var type: String {
        get {
            return ElfoPublishableType.log.rawValue
        }
    }
    
    static var group: String {
        get {
            return ElfoPublishableGroup.analytics.rawValue
        }
    }
    
    var kind: String {
        get {
            return ElfoPublishableKind.mixpanelEvent.rawValue
        }
    }
    
    let title: String
    let properties: String
}
#endif
