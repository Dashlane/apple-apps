import Foundation

public struct TOTPActivationResponse: Decodable {
    public let seed: String
    public let serverKey: String
    public let uri: String
    public let recoveryKeys: [String]
    
    public init(seed: String,
                serverKey: String,
                uri: String,
                recoveryKeys: [String]) {
        self.seed = seed
        self.serverKey = serverKey
        self.uri = uri
        self.recoveryKeys = recoveryKeys
    }
}
