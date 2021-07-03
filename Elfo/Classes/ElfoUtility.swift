//
//  Utility.swift
//  Elfo
//
//  Created by Douwe Bos on 12/12/20.
//

import Foundation

/**
 let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
 let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
 */

struct ElfoUtility {
    static var uuid: String {
        get {
            return UUID().uuidString
        }
    }
    
    static var projectName: String {
        get {
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Elfo Application"
        }
    }
    
    static var deviceId: String {
        get {
            return [deviceName, deviceDescription].joined(separator: "-")
        }
    }
    
    static var deviceName: String {
        get {
            return UIDevice.current.name
        }
    }
    
    static var deviceDescription: String {
        get {
            return [
                UIDevice.current.model,
                UIDevice.current.systemName,
                UIDevice.current.systemVersion
            ].joined(separator: " ")
        }
    }
}

internal extension Encodable {
    var asData: Data? {
        get {
            return try? JSONEncoder().encode(self)
        }
    }
}

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
    
    var asJSON: [String: Any?]? {
        get {
            return (try? JSONSerialization.jsonObject(with: self)) as? [String: Any?]
        }
    }
    
    var asArray: [Any]? {
        get {
            return (try? JSONSerialization.jsonObject(with: self)) as? [Any]
        }
    }
    
    var asString: String? {
        get {
            return String(decoding: self, as: UTF8.self)
        }
    }
}

internal extension Dictionary where Key == String, Value == Any? {
    var asData: Data? {
        get {
            return try? JSONSerialization.data(withJSONObject: self)
        }
    }
    
    var prettyPrinted: Data? {
        get {
            return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        }
    }
    
    var prettyPrintedString: String? {
        get {
            guard let pretty = self.prettyPrinted else { return nil }
            return String(data: pretty, encoding: .utf8)
        }
    }
    
    var jsonString: String? {
        get {
            return (try? JSONSerialization.data(withJSONObject: self))?.asString?.replacingOccurrences(of: "\\", with: "")
        }
    }
}
