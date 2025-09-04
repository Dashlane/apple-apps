import Combine
import CorePersonalData
import CoreTypes
import DashlaneAPI
import Foundation
import IconLibrary
import SecurityDashboard

class DarkWebMonitoringEmailRowViewModel: ObservableObject, SessionServicesInjecting {
  @Published
  var icon: Icon?
  let status: DataLeakEmail.State
  let title: String
  let actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
  let iconLibrary: GravatarIconLibraryProtocol

  init(
    email: DataLeakEmail,
    iconService: IconServiceProtocol,
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
  ) {
    self.title = email.email
    self.status = DataLeakEmail.State(rawValue: email.state) ?? .disabled
    self.actionPublisher = actionPublisher
    self.iconLibrary = iconService.gravatar
  }

  func makeGravatarIconViewModel() -> GravatarIconViewModel {
    GravatarIconViewModel(email: title, iconLibrary: iconLibrary)
  }
}
