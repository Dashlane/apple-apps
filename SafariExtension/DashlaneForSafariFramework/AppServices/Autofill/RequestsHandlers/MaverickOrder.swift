import Foundation

struct MaverickOrder: Decodable {
    let id: Int
    let tabId: String
    let message: MaverickOrderMessage
}

struct MaverickOrderMessage: Decodable {
    let action: String
    let request: String?

    private struct Request: Decodable {
        let id: String
    }

    var requestID: String? {
        guard let data = request?.data(using: .utf8) else { return nil }
        guard let request = try? JSONDecoder().decode(Request.self, from: data) else { return nil }
        return request.id
    }

    func content<Request: Decodable>(using decoder: JSONDecoder = JSONDecoder()) -> Request? {
        guard let request = request else { return nil }
        guard let jsonData = request.data(using: .utf8) else { return nil }

        guard let decodedRequest = try? decoder.decode(Request.self, from: jsonData) else {
            return nil
        }
        return decodedRequest
    }

    private struct MaverickOrderActionTypeDecoder<ActionType: MaverickAction>: Decodable {
        let type: ActionType
        let tabId: Int?
    }

    func maverickAction<ActionType: MaverickAction>() -> ActionType? {
        let response: MaverickOrderActionTypeDecoder<ActionType>? = content()
        return response?.type
    }
    
    func tabId() -> Int? {
        if let action: MaverickOrderActionTypeDecoder<MaverickNonAuthenticatedAction> = content() {
            return action.tabId
        } else if let action: MaverickOrderActionTypeDecoder<MaverickAuthenticatedAction> = content() {
            return action.tabId
        }
        return nil
    }

    init(action: String, requestDict: [String: Any]) {
        self.action = action
        let data = try! JSONSerialization.data(withJSONObject: requestDict)
        self.request = String(bytes: data, encoding: .utf8)!
    }

    init(action: String, request: String) {
        self.action = action
        self.request = request
    }
}

extension MaverickOrderMessage: CustomStringConvertible {
    var description: String {
        "\(self.requestID ?? "No ID") - \(self.request ?? "-")"
    }
}
