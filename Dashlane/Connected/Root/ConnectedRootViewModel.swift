import SwiftUI

@MainActor
class ConnectedRootViewModel: ObservableObject, SessionServicesInjecting {
  let iphoneRootViewModelFactory: ConnectedIphoneRootViewModel.Factory
  let ipadMacRootViewModelFactory: ConnectedIpadMacRootViewModel.Factory
  let connectedEnvironmentModelFactory: ConnectedEnvironmentModel.Factory
  let accessControlModelFactory: AccessControlRequestViewModifierModel.Factory

  init(
    iphoneRootViewModelFactory: ConnectedIphoneRootViewModel.Factory,
    ipadMacRootViewModelFactory: ConnectedIpadMacRootViewModel.Factory,
    connectedEnvironmentModelFactory: ConnectedEnvironmentModel.Factory,
    accessControlModelFactory: AccessControlRequestViewModifierModel.Factory
  ) {
    self.iphoneRootViewModelFactory = iphoneRootViewModelFactory
    self.ipadMacRootViewModelFactory = ipadMacRootViewModelFactory
    self.connectedEnvironmentModelFactory = connectedEnvironmentModelFactory
    self.accessControlModelFactory = accessControlModelFactory
  }
}
