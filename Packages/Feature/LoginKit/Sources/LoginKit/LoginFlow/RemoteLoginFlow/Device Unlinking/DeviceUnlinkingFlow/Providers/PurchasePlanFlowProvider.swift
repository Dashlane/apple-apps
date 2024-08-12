import CoreSession
import DashTypes
import Foundation
import SwiftUI

public enum PurchasePlanFlowCompletion {
  case successful
  case cancel
}

public protocol PurchasePlanFlowProvider {
  @ViewBuilder func makePurchasePlanFlow(
    for login: Login,
    authentication: ServerAuthentication,
    completion: @escaping (PurchasePlanFlowCompletion) -> Void
  ) async throws -> AnyView
}
