import Foundation

public struct ServerError: Decodable {
    public let objectType: String
    public let content: String
}
