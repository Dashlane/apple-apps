import Foundation

struct MaverickResponseMessage: Encodable {
    let action: String = "mfaResponse"
    let content: String
}

extension Communication {
    static func from(_ message: MaverickResponseMessage, order: MaverickOrder) -> Communication {
        let response = MaverickResponse(id: order.id, tabId: order.tabId, message: message)
        let body = response.communicationBody()
        
        return Communication(from: .unspecified,
                             to: .background,
                             subject: "mfaResponse",
                             body: body)
    }
}
