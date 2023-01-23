import Foundation
import SwiftUI
import CoreSession
import DashTypes

public enum PurchasePlanFlowCompletion {
    case successful
    case cancel
}

public protocol PurchasePlanFlowProvider {
    @ViewBuilder func makePurchasePlanFlow(for login: Login,
                                           authentication: ServerAuthentication,
                                           completion: @escaping (PurchasePlanFlowCompletion) -> Void) -> AnyView
}
