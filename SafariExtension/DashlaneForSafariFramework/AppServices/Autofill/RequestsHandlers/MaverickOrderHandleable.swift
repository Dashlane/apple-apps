import Foundation

protocol MaverickOrderResponse: Encodable {
    var id: String { get }
}

protocol MaverickOrderHandleable {

    associatedtype Request: Decodable
    associatedtype Response: MaverickOrderResponse

    func performOrder() throws -> Response?
    func makeResponse() throws -> AnyEncodable?

    var maverickOrderMessage: MaverickOrderMessage { get }
}

extension MaverickOrderHandleable {

   func makeResponse() throws -> AnyEncodable? {
        guard let response = try performOrder() else {
            return nil
        }
        return AnyEncodable(response)
    }

    var actionMessageID: String {
        assert(maverickOrderMessage.requestID != nil, "We should have a request ID to answer maverick")
        return maverickOrderMessage.requestID ?? ""
    }
}

struct MaverickEmptyRequest: Decodable {}
struct MaverickEmptyResponse: MaverickOrderResponse {
    let id: String
}
