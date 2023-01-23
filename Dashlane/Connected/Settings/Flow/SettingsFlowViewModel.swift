import Combine
import Foundation
import DashlaneAppKit
import CoreUserTracking
import UIDelight
import ImportKit
import DashTypes
import UIKit

@MainActor
final class SettingsFlowViewModel: ObservableObject, SessionServicesInjecting {

    enum Step {
        case main
        case security
        case general
        case helpCenter
        case `import`(DashImportFlowViewModel) 
        case labs
    }

    @Published
    var steps: [Step]

    private var cancellables: Set<AnyCancellable> = []

    let labsService = LabsService()

    let mainSettingsViewModelFactory: MainSettingsViewModel.Factory
    let securitySettingsViewModelFactory: SecuritySettingsViewModel.Factory
    let generalSettingsViewModelFactory: GeneralSettingsViewModel.Factory
    let helpCenterSettingsViewModelFactory: HelpCenterSettingsViewModel.Factory
    let labsSettingsViewModelFactory: LabsSettingsViewModel.Factory

    init(mainSettingsViewModelFactory: MainSettingsViewModel.Factory,
         securitySettingsViewModelFactory: SecuritySettingsViewModel.Factory,
         generalSettingsViewModelFactory: GeneralSettingsViewModel.Factory,
         helpCenterSettingsViewModelFactory: HelpCenterSettingsViewModel.Factory,
         labsSettingsViewModelFactory: LabsSettingsViewModel.Factory) {
        self.mainSettingsViewModelFactory = mainSettingsViewModelFactory
        self.securitySettingsViewModelFactory = securitySettingsViewModelFactory
        self.generalSettingsViewModelFactory = generalSettingsViewModelFactory
        self.helpCenterSettingsViewModelFactory = helpCenterSettingsViewModelFactory
        self.labsSettingsViewModelFactory = labsSettingsViewModelFactory
        _steps = .init(initialValue: [.main])
    }

    func handleMainAction(_ action: MainSettingsView.Action) {

        switch action {
        case .displaySecuritySettings:
            self.steps.append(.security)
        case .displayGeneralSettings:
            self.steps.append(.general)
        case .displayHelpCenter:
            self.steps.append(.helpCenter)
        case .displayLabs:
            self.steps.append(.labs)
        }
    }

    func handleGeneralSettingsAction(_ action: GeneralSettingsView.Action) {
        switch action {
        case .displayImportFlow(let viewModel):
            viewModel.dismissPublisher.sink { [weak self] action in
                guard let self = self,
                      let window = UIApplication.shared.keyUIWindow,
                      let splitVC = window.rootViewController as? UISplitViewController,
                      let tabBarVC = splitVC.viewControllers.first as? TabSelectable
                        ?? splitVC.viewController(for: .primary) as? TabSelectable else {
                    return
                }
                switch action {
                case .dismiss:
                    _ = self.steps.popLast()
                    tabBarVC.selectTab(.home, coordinator: nil)
                default:
                    break
                }
            }.store(in: &cancellables)
            steps.append(.import(viewModel))
        }
    }

}

extension SettingsFlowViewModel {

    static var mock: SettingsFlowViewModel {
        SettingsFlowViewModel(mainSettingsViewModelFactory: .init({ _ in .mock() }),
                              securitySettingsViewModelFactory: .init({ .mock }),
                              generalSettingsViewModelFactory: .init({ .mock }),
                              helpCenterSettingsViewModelFactory: .init({ .mock }),
                              labsSettingsViewModelFactory: .init({ _ in .mock }))
    }
}
