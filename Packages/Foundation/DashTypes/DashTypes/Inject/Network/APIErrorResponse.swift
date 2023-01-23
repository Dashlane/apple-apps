import Foundation

public struct APIErrorResponse: Error, Decodable, Equatable {
    public let requestId: String
    public let errors: [APIError]
    
    public init(requestId: String, errors: [APIError]) {
        self.requestId = requestId
        self.errors = errors
    }
}

public struct APIError: Error, Decodable, Equatable {
    public let code: String
    public let message: String
    public let type: String
    
    public init(code: String, message: String, type: String) {
        self.code = code
        self.message = message
        self.type = type
    }
}
