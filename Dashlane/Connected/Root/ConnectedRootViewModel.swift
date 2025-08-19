import Combine
import LoginKit
import SwiftUI

@MainActor
class ConnectedRootViewModel: ObservableObject, SessionServicesInjecting {
  let iphoneRootViewModelFactory: ConnectedIphoneRootViewModel.Factory
  let ipadMacRootViewModelFactory: ConnectedIpadMacRootViewModel.Factory
  let connectedEnvironmentModelFactory: ConnectedEnvironmentModel.Factory
  let accessControlModelFactory: AccessControlRequestViewModifierModel.Factory
  let securityAuthTokenAlertModel: SecurityAuthTokenAlertModifierModel.Factory
  let breachPopupAlertModelFactory: BreachPopupAlertModifierModel.Factory

  init(
    iphoneRootViewModelFactory: ConnectedIphoneRootViewModel.Factory,
    ipadMacRootViewModelFactory: ConnectedIpadMacRootViewModel.Factory,
    connectedEnvironmentModelFactory: ConnectedEnvironmentModel.Factory,
    accessControlModelFactory: AccessControlRequestViewModifierModel.Factory,
    securityAuthTokenAlertModel: SecurityAuthTokenAlertModifierModel.Factory,
    breachPopupAlertModelFactory: BreachPopupAlertModifierModel.Factory
  ) {
    self.iphoneRootViewModelFactory = iphoneRootViewModelFactory
    self.ipadMacRootViewModelFactory = ipadMacRootViewModelFactory
    self.connectedEnvironmentModelFactory = connectedEnvironmentModelFactory
    self.accessControlModelFactory = accessControlModelFactory
    self.securityAuthTokenAlertModel = securityAuthTokenAlertModel
    self.breachPopupAlertModelFactory = breachPopupAlertModelFactory
  }
}
