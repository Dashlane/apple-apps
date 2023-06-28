import Foundation
import DashlaneAppKit
import CoreSettings

struct IsReactivationEnabledHandler: MaverickOrderHandleable {

    typealias Request = MaverickEmptyRequest

    struct Response: MaverickOrderResponse {
        let id: String
        let showReactivation: Bool
    }

    let maverickOrderMessage: MaverickOrderMessage
    let settings: AppSettings

    func performOrder() throws -> Response? {
        return Response(id: actionMessageID, showReactivation: settings.getWebCardActivation())
    }
}

private extension AppSettings {
    func getWebCardActivation() -> Bool {
        return self.safariWebCardActivated ?? true
    }

}
