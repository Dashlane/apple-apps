import Foundation
import DashTypes

public typealias DataParser<A> = (Data) -> Result<A, Error>

public enum ResourceError: Error, Equatable {
    case noBody
    case parseError(_ error: Error?)
    case serverFeedback(code: Int, message: String?, content: Any?)

    public static func == (lhs: ResourceError, rhs: ResourceError) -> Bool {
        switch (lhs, rhs) {
        case (.parseError, .parseError):
            return true
        case let (.serverFeedback(lCode, lMessage, _), .serverFeedback(rCode, rMessage, _)):
            return lCode == rCode && lMessage == rMessage
        default:
            return false
        }
    }
}

public struct Resource<A> {

    public let request: Request
    public let parse: DataParser<A>
    
    public init(request: Request, parse: @escaping DataParser<A> ) {
        self.request = request
        self.parse = parse
    }

}
