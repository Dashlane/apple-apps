import Foundation
import DashTypes

public struct Nothing {
    public init?(json: Any?) {
            }
}

public struct ParserBuilder<A> {
    public typealias JSONParser<A> = (Any?) -> A?
    public typealias JSONDictionary = [String: Any]

    private let parse: JSONParser<A>

    public init( _ parse: @escaping JSONParser<A> ) {
        self.parse = parse
    }

    public func build() -> DataParser<A> {
        return { data in
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                guard let root = json as? JSONDictionary,
                      let code = root[ResponseKey.code] as? Int
                else {
                    return .failure(ResourceError.parseError(nil))
                }

                guard code == 200 else {
                    let message = root[ResponseKey.message] as? String
                    let content = root[ResponseKey.content]
                    return .failure(ResourceError.serverFeedback(code: code, message: message, content: content))
                }

                guard let parsed = self.parse( root[ResponseKey.content] ) else {
                    return .failure(ResourceError.parseError(nil))
                }

                return .success(parsed)
            } catch {
                return .failure(ResourceError.parseError(error))
            }
        }
    }

}
