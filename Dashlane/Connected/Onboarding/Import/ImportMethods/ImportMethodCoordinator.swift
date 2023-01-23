import DashlaneAppKit
import SwiftTreats
import ImportKit
import Foundation
import UIKit

class ImportMethodCoordinator: NSObject, Coordinator, SubcoordinatorOwner {

        private let contextNavigator: DashlaneNavigationController?

    private let navigator: DashlaneNavigationController
    private let sessionServices: SessionServicesContainer
    private let importService: ImportMethodServiceProtocol
    private let viewModelFactory: ViewModelFactory
    private let completion: (Completion) -> Void
    var subcoordinator: Coordinator?

    enum Step {
        case importMethod
        case addPasswordManually
        case keychainInstructions
        case chromeImport
        case dashImport
        case keychainImport
    }

    enum Completion {
        case finished
    }

    init(contextNavigator: DashlaneNavigationController?, internalNavigator: DashlaneNavigationController? = nil, sessionServices: SessionServicesContainer, mode: ImportMethodMode, completion: @escaping (Completion) -> Void) {
        self.sessionServices = sessionServices
        self.contextNavigator = contextNavigator
        self.importService = ImportMethodService(featureService: sessionServices.featureService, mode: mode)
        self.viewModelFactory = sessionServices
        self.navigator = internalNavigator ?? DashlaneNavigationController()
        self.navigator.modalPresentationStyle = Device.isIpadOrMac ? .formSheet : .fullScreen
        self.navigator.isModalInPresentation = true
        self.completion = completion
    }

    func start() {
        move(to: .importMethod)
        contextNavigator?.present(navigator, animated: true)
    }

    private func move(to step: Step) {
        switch step {
        case .importMethod:
            navigator.push(makeImportMethodView(importService: importService))
        case .addPasswordManually:
            showAddPassword()
        case .keychainInstructions:
            showKeychainInstructions()
        case .chromeImport:
            showChromeImport()
        case .dashImport:
            showDashImport()
        case .keychainImport:
            showKeychainImport()
        }
    }

    private func showMethod(_ method: ImportMethod) {
        switch method {
        case .manual:
            move(to: .addPasswordManually)
        case .dash:
            move(to: .dashImport)
        case .keychain:
            move(to: .keychainInstructions)
        case .keychainCSV:
            move(to: .keychainImport)
        case .chrome:
            move(to: .chromeImport)
        }
    }

    private func makeImportMethodView(importService: ImportMethodServiceProtocol) -> ImportMethodView<ImportMethodViewModel> {
        let viewModel = sessionServices.viewModelFactory.makeImportMethodViewModel(importService: importService) { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .back:
                self.dismiss()
            case .methodSelected(let method):
                self.showMethod(method)
            case .dwmScanRequested:
                self.sessionServices.appServices.deepLinkingService.handleLink(.tool(.darkWebMonitoring, origin: "onboarding_vault"))
            case .dwmScanPromptDismissed:
                self.sessionServices.dwmOnboardingSettings[.hasDismissedLastChanceScanPrompt] = true
            }
        }
        return ImportMethodView(viewModel: viewModel)
    }

    private func makeImportFlowView<Model: ImportFlowViewModel>(viewModel: Model) -> ImportFlowView<Model> {
        return ImportFlowView(viewModel: viewModel) { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .popToRootView:
                self.navigator.popToRootViewController(animated: true)
            case .dismiss:
                self.navigator.dismiss()
            }
        }
    }

    private func showAddPassword() {
        subcoordinator = AddItemCoordinator(sessionServices: sessionServices,
                                             displayMode: .categoryDetail(.credentials),
                                             navigator: navigator) { [weak self] in
                                                self?.subcoordinator = nil
        }

        subcoordinator?.start()
    }

    private func showKeychainInstructions() {
        let view = KeychainInstructionsView { [weak self] result in
            switch result {
            case .goToSettings:
                let settings = URL(string: "App-prefs://")!
                UIApplication.shared.open(settings)
            case .cancel:
                self?.navigator.pop()
            }
        }
        self.navigator.push(view)
    }

    private func showChromeImport() {
        if sessionServices.featureService.isEnabled(.chromeImport) {
            let viewModel = ChromeImportFlowViewModel(userSettings: sessionServices.spiegelUserSettings)
            navigator.push(makeImportFlowView(viewModel: viewModel))
        } else {
            subcoordinator = ChromeImportCoordinator(navigator: navigator, sessionServices: sessionServices)
            subcoordinator?.start()
        }
    }

    private func showDashImport() {
        let viewModel = DashImportFlowViewModel(
            personalDataURLDecoder: sessionServices.appServices.personalDataURLDecoder,
            applicationDatabase: sessionServices.database,
            databaseDriver: sessionServices.databaseDriver,
            iconService: sessionServices.iconService,
            activityReporter: sessionServices.activityReporter)
        navigator.push(makeImportFlowView(viewModel: viewModel))
    }

    private func showKeychainImport() {
        let viewModel = KeychainImportFlowViewModel(
            personalDataURLDecoder: sessionServices.appServices.personalDataURLDecoder,
            applicationDatabase: sessionServices.database,
            iconService: sessionServices.iconService,
            activityReporter: sessionServices.activityReporter)
        navigator.push(makeImportFlowView(viewModel: viewModel))
    }

    internal func dismiss() {
                if contextNavigator != nil {
            self.navigator.dismiss(animated: true, completion: nil)
        }
        completion(.finished)
    }
}
