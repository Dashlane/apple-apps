import Combine
import CorePremium
import CoreUserTracking
import DashTypes
import Foundation
import ImportKit
import SwiftUI
import UIDelight
import UIKit

@MainActor
final class SettingsFlowViewModel: ObservableObject, SessionServicesInjecting {
  @Published
  var subSectionsPath: [SettingsSubSection] = []

  private var cancellables: Set<AnyCancellable> = []
  private let mainSettingsViewModelFactory: MainSettingsViewModel.Factory
  let securitySettingsViewModelFactory: SecuritySettingsViewModel.Factory
  let generalSettingsViewModelFactory: GeneralSettingsViewModel.Factory
  let helpCenterSettingsViewModelFactory: HelpCenterSettingsViewModel.Factory
  private let labsSettingsViewModelFactory: LabsSettingsViewModel.Factory
  private let accountSummaryViewModelFactory: AccountSummaryViewModel.Factory

  init(
    mainSettingsViewModelFactory: MainSettingsViewModel.Factory,
    securitySettingsViewModelFactory: SecuritySettingsViewModel.Factory,
    generalSettingsViewModelFactory: GeneralSettingsViewModel.Factory,
    helpCenterSettingsViewModelFactory: HelpCenterSettingsViewModel.Factory,
    labsSettingsViewModelFactory: LabsSettingsViewModel.Factory,
    accountSummaryViewModelFactory: AccountSummaryViewModel.Factory,
    deepLinkingService: DeepLinkingServiceProtocol
  ) {
    self.mainSettingsViewModelFactory = mainSettingsViewModelFactory
    self.securitySettingsViewModelFactory = securitySettingsViewModelFactory
    self.generalSettingsViewModelFactory = generalSettingsViewModelFactory
    self.helpCenterSettingsViewModelFactory = helpCenterSettingsViewModelFactory
    self.labsSettingsViewModelFactory = labsSettingsViewModelFactory
    self.accountSummaryViewModelFactory = accountSummaryViewModelFactory
    deepLinkingService.settingsComponentPublisher().map { link in
      switch link {
      case .root:
        return []
      case .security:
        return [.security]
      }
    }.assign(to: &$subSectionsPath)
  }

  func makeMainViewModel() -> MainSettingsViewModel {
    mainSettingsViewModelFactory.make()
  }

  func makeLabsViewModel() -> LabsSettingsViewModel {
    labsSettingsViewModelFactory.make()
  }

  func makeAccountSummaryViewModel() -> AccountSummaryViewModel {
    accountSummaryViewModelFactory.make()
  }
}

extension SettingsFlowViewModel {

  static var mock: SettingsFlowViewModel {
    SettingsFlowViewModel(
      mainSettingsViewModelFactory: .init({ .mock() }),
      securitySettingsViewModelFactory: .init({ .mock }),
      generalSettingsViewModelFactory: .init({ .mock(status: .Mock.free) }),
      helpCenterSettingsViewModelFactory: .init({ .mock }),
      labsSettingsViewModelFactory: .init({ .mock }),
      accountSummaryViewModelFactory: .init({ .mock }),
      deepLinkingService: DeepLinkingService.fakeService)
  }
}
