import Foundation
import DashTypes

public struct IPCUnsecureMessageCoder: IPCMessageCoderProtocol {
    public init() {
    }
    
    public func encode<T>(_ message: T) throws -> Data where T : Encodable {
        return try JSONEncoder().encode(message)
    }
    
    public func decode<T>(_ data: Data) throws -> T where T : Decodable {
        guard !data.isEmpty else {
            throw IPCMessageCoderError.noData
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
