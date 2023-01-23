import Foundation

public struct ServerResponse<T: Decodable>: Decodable {
    public let code: Int
    public let message: String
    public let content: T
}
