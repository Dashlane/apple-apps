import Foundation


public enum Endpoint: Hashable {
    case unspecified
    case broadcast
    case background
    case injected
    case plugin
    case popover
    case webAnalysis
    case carbon
    case other(String)

    init(stringValue: String) {
        switch stringValue {
        case "Unspecified":
            self = .unspecified
        case "Broadcast":
            self = .broadcast
        case "Background":
            self = .background
        case "Injected":
            self = .injected
        case "Plugin":
            self = .plugin
        case "Popover":
            self = .popover
        case "WebAnalysis":
            self = .webAnalysis
        case "Carbon":
            self = .carbon
        default:
            self = .other(stringValue)
        }

    }
}

extension Endpoint {
    public var stringValue: String {
        switch self {
        case .unspecified:
            return "Unspecified"
        case .broadcast:
            return "Broadcast"
        case .background:
            return "Background"
        case .injected:
            return "Injected"
        case .plugin:
            return "Plugin"
        case .popover:
            return "Popover"
        case .webAnalysis:
            return "WebAnalysis"
        case .carbon:
            return "Carbon"
        case .other(let name):
            return name
        }
    }
}

public struct Communication {
    
    public let from: Endpoint
    public let to: Endpoint
    public let subject: String
    public let body: [String: Any]
    
    public init(from: String, to: String, subject: String, body: [String: Any] = [:]) {
        self.from = Endpoint(stringValue: from)
        self.to = Endpoint(stringValue: to)
        self.subject = subject
        self.body = body
    }
}

extension Communication: CustomStringConvertible {
    public var description: String {
        return "from: \(from) to: \(to) subject: \(subject) body: \(body)"
    }
}

extension Communication {
    
    public init(from: Endpoint, to: Endpoint, subject: String, body: [String: Any] = [:]) {
        self.from = from
        self.to = to
        self.subject = subject
        self.body = body
    }
    
    public init(subject: String, body: [String: Any] = [:]) {
        self.from = Endpoint.unspecified
        self.to = Endpoint.unspecified
        self.subject = subject
        self.body = body
    }
    
    public func update(from: Endpoint, to: Endpoint) -> Communication {
        return Communication(from: from, to: to, subject: self.subject, body: self.body)
    }
    
        public var userInfo: [AnyHashable: Any] {
        var result = [AnyHashable: Any]()
        result["from"] = from
        result["to"] = to
        result["subject"] = subject
        result["body"] = body
        return result
    }
    
    public init?(userInfo: [AnyHashable: Any]) {
        guard let from = userInfo["from"] as? String else { return nil }
        guard let to = userInfo["to"] as? String else { return nil }
        guard let subject = userInfo["subject"] as? String else { return nil }
        guard let body = userInfo["body"] as? [String: Any] else { return nil }
        self = Communication(from: from, to: to, subject: subject, body: body)
    }
    
        public static func toBody<T: Codable>(_ codable: T) -> [String: Any] {
        guard let data = try? JSONEncoder().encode(codable) else {
            preconditionFailure("cannot encode")
        }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
            preconditionFailure("cannot decode")
        }
        guard let body = jsonObject as? [String: Any] else {
            preconditionFailure("not a dictionary")
        }
        return body
    }
    
    public func fromBody<T>(_ type: T.Type) -> T? where T : Decodable {
        guard let data = try? JSONSerialization.data(withJSONObject: self.body) else {
            preconditionFailure("cannot encode")
        }
        guard let result = try? JSONDecoder().decode(type, from: data) else {
            return nil
        }
        return result
    }

            var isValid: Bool {
        return JSONSerialization.isValidJSONObject(self.body)
    }
}


extension Communication {
    public var prettyPrinted: String {
        guard let prettyBody = prettyPrint(body) else {
            return self.description
        }
        return "from: \(from) to: \(to) subject: \(subject) body: \(prettyBody)"
    }
}

private func prettyPrint(_ jsonObject: Any) -> String? {
    let options: JSONSerialization.WritingOptions
    options = [.prettyPrinted, .sortedKeys]
    guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: options),
        let text = String(bytes: jsonData, encoding: .utf8) else {
            return nil
    }
    return text
}
