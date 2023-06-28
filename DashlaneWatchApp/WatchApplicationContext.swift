import Foundation

extension URL {
    static func contextUrl() -> URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = documentsPath + "/applicationContext.json"
        return URL(fileURLWithPath: path)
    }
}

final class WatchApplicationContext: Codable {
    
    struct Token: Codable, Identifiable {
        var url: URL
        var title: String
        
        var id: String {
            "\(title)-\(url)"
        }
    }
    
    var tokens: [Token]
    
    init(tokens: [Token] = []) {
        self.tokens = tokens
    }
    
    func toDict() throws -> [String: Any]  {
        let data = try JSONEncoder().encode(self)
        let dict = try JSONSerialization.jsonObject(with: data)
        return dict as! [String: Any]
    }
    
    static func fromDict(_  dict: [String: Any] ) throws -> WatchApplicationContext {
        let data = try JSONSerialization.data(withJSONObject: dict)
        let context = try JSONDecoder().decode(WatchApplicationContext.self, from: data)
        return context
    }

}

struct WatchFeedbackMessage: Codable {
    
    enum Action: String, Codable {
        case refreshContext
        case messageSetupTotp
        case totpCodeList
    }
    
    var action: Action
    
    func toDict() throws -> [String: Any]  {
        let data = try JSONEncoder().encode(self)
        let dict = try JSONSerialization.jsonObject(with: data)
        return dict as! [String: Any]
    }
    
    static func fromDict(_  dict: [String: Any] ) throws -> WatchFeedbackMessage {
        let data = try JSONSerialization.data(withJSONObject: dict)
        let context = try JSONDecoder().decode(WatchFeedbackMessage.self, from: data)
        return context
    }
    
}


