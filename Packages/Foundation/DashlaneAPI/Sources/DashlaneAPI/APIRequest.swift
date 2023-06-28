import Foundation

public typealias Endpoint = String

public protocol APIRequest {
    associatedtype Response: Codable
    associatedtype Body: Encodable
    static var endpoint: String { get }
}

extension APIRequest {
   typealias Body = Empty
}
