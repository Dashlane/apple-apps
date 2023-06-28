import Combine
import Foundation
import DashlaneAppKit
import CoreUserTracking
import UIDelight
import ImportKit
import DashTypes
import UIKit
import SwiftUI

@MainActor
final class SettingsFlowViewModel: ObservableObject, SessionServicesInjecting {
    @Published
    var subSectionsPath: [SettingsSubSection] = []

    private var cancellables: Set<AnyCancellable> = []
    private let labsService = LabsService()
    private let mainSettingsViewModelFactory: MainSettingsViewModel.Factory
    let securitySettingsViewModelFactory: SecuritySettingsViewModel.Factory
    let generalSettingsViewModelFactory: GeneralSettingsViewModel.Factory
    let helpCenterSettingsViewModelFactory: HelpCenterSettingsViewModel.Factory
    private let labsSettingsViewModelFactory: LabsSettingsViewModel.Factory

    init(mainSettingsViewModelFactory: MainSettingsViewModel.Factory,
         securitySettingsViewModelFactory: SecuritySettingsViewModel.Factory,
         generalSettingsViewModelFactory: GeneralSettingsViewModel.Factory,
         helpCenterSettingsViewModelFactory: HelpCenterSettingsViewModel.Factory,
         labsSettingsViewModelFactory: LabsSettingsViewModel.Factory,
         deepLinkingService: DeepLinkingServiceProtocol) {
        self.mainSettingsViewModelFactory = mainSettingsViewModelFactory
        self.securitySettingsViewModelFactory = securitySettingsViewModelFactory
        self.generalSettingsViewModelFactory = generalSettingsViewModelFactory
        self.helpCenterSettingsViewModelFactory = helpCenterSettingsViewModelFactory
        self.labsSettingsViewModelFactory = labsSettingsViewModelFactory
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
        mainSettingsViewModelFactory.make(labsService: labsService)
    }

    func makeLabsViewModel() -> LabsSettingsViewModel {
        labsSettingsViewModelFactory.make(labsService: labsService)
    }
}

extension SettingsFlowViewModel {

    static var mock: SettingsFlowViewModel {
        SettingsFlowViewModel(mainSettingsViewModelFactory: .init({ _ in .mock() }),
                              securitySettingsViewModelFactory: .init({ .mock }),
                              generalSettingsViewModelFactory: .init({ .mock }),
                              helpCenterSettingsViewModelFactory: .init({ .mock }),
                              labsSettingsViewModelFactory: .init({ _ in .mock }),
                              deepLinkingService: DeepLinkingService.fakeService)
    }
}
