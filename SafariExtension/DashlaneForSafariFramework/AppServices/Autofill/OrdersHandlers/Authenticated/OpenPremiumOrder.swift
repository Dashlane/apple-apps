import Foundation
import Cocoa

struct OpenPremiumOrder: MaverickOrderHandleable {

    typealias Request = MaverickEmptyRequest
    typealias Response = MaverickEmptyResponse

    let maverickOrderMessage: MaverickOrderMessage

    func performOrder() throws -> Response? {
        guard let url = DeepLink.other(.getPremium, origin: nil).urlRepresentation else {
            return nil
        }
        NSWorkspace.shared.open(url)
        return nil
    }
}
