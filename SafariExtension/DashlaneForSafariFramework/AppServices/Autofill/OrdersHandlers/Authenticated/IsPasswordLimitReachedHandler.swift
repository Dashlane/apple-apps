import Foundation
import CorePremium
import DashTypes

struct IsPasswordLimitReachedHandler: MaverickOrderHandleable, SessionServicesInjecting {
    
    typealias Request = MaverickEmptyRequest
    
    struct Response: MaverickOrderResponse {
        let id: String
        let isPwLimitReached: Bool
    }
    
    let maverickOrderMessage: MaverickOrderMessage
    
    init(maverickOrderMessage: MaverickOrderMessage) {
        self.maverickOrderMessage = maverickOrderMessage
    }
    
    func performOrder() throws -> Response? {
        return Response(id: actionMessageID, isPwLimitReached: false)
    }
}
