import Foundation
import DashTypes

public struct JSONParserBuilder<A: Decodable> {

    public init() { }

    public func build() -> DataParser<A> {
        return { data in
            do {
                let response = try JSONDecoder().decode(DashlaneResponse<A>.self, from: data)
                return .success(response.content)
            } catch {
                do {
                    let errorResponse = try JSONDecoder().decode(DashlaneResponse<Message>.self, from: data)
                    return .failure(ResourceError.serverFeedback(code: errorResponse.code, message: errorResponse.message, content: errorResponse.content))
                } catch {
                    return .failure(ResourceError.parseError(error))
                }
            }
        }
    }
}

public struct JSONResponseParser<A: Decodable>: ResponseParserProtocol {

    public init() { }

    public func parse(data: Data) throws -> A {
        return try JSONDecoder().decode(DashlaneResponse<A>.self, from: data).content
    }
}
