import Foundation
import ImportKit
import UIKit

@MainActor
final class ImportMethodFlowViewModel: ObservableObject, SessionServicesInjecting {

  enum Completion {
    case dismiss
  }

  enum Step {
    case addItem(AddItemFlowViewModel)
    case importView(ImportMethodViewModel)
    case chromeFlow(ImportFlowView<ChromeImportFlowViewModel>)
    case dashFlow(ImportFlowView<DashImportFlowViewModel>)
    case keychainFlow(ImportFlowView<KeychainImportFlowViewModel>)
    case keychainInstructions(KeychainInstructionsView)
  }

  @Published
  var steps: [Step] = []

  private let completion: (Completion) -> Void

  private let importMethodViewModelFactory: ImportMethodViewModel.Factory
  private let addItemFlowViewModelFactory: AddItemFlowViewModel.Factory

  private let sessionServices: SessionServicesContainer
  private let importService: ImportMethodServiceProtocol

  init(
    mode: ImportMethodMode,
    completion: @escaping (ImportMethodFlowViewModel.Completion) -> Void,
    sessionServices: SessionServicesContainer,
    importMethodViewModelFactory: ImportMethodViewModel.Factory,
    addItemFlowViewModelFactory: AddItemFlowViewModel.Factory
  ) {
    self.completion = completion

    self.sessionServices = sessionServices
    self.importService = ImportMethodService(
      featureService: sessionServices.featureService, mode: mode)

    self.importMethodViewModelFactory = importMethodViewModelFactory
    self.addItemFlowViewModelFactory = addItemFlowViewModelFactory

    start()
  }

  private func start() {
    steps = [
      .importView(
        importMethodViewModelFactory.make(
          importService: importService,
          completion: { self.handleImportMethodViewAction($0) })
      )
    ]
  }

  private func methodSelected(_ method: LegacyImportMethod) {
    switch method {
    case .manual:
      showAddPassword()
    case .dash:
      showDashImport()
    case .keychain:
      showKeychainInstructions()
    case .keychainCSV:
      showKeychainImport()
    case .chrome:
      showChromeImport()
    }
  }

  private func showAddPassword() {
    let viewModel = addItemFlowViewModelFactory.make(displayMode: .categoryDetail(.credentials)) {
      [weak self] completion in
      switch completion {
      case .dismiss:
        self?.completion(.dismiss)
      }
    }

    steps.append(.addItem(viewModel))
  }

  private func showKeychainInstructions() {
    steps.append(
      .keychainInstructions(
        KeychainInstructionsView { [weak self] result in
          switch result {
          case .goToSettings:
            UIApplication.shared.open(URL(string: "App-prefs://")!)
          case .cancel:
            self?.steps.removeLast()
          }
        }
      )
    )
  }

  private func showChromeImport() {
    let viewModel = sessionServices.makeChromeImportFlowViewModel(
      userSettings: sessionServices.spiegelUserSettings)
    let view = ImportFlowView(
      viewModel: viewModel, completion: { self.handleImportFlowViewAction($0) })

    steps.append(.chromeFlow(view))
  }

  private func showDashImport() {
    let viewModel = sessionServices.makeDashImportFlowViewModel(
      applicationDatabase: sessionServices.database, databaseDriver: sessionServices.databaseDriver)
    let view = ImportFlowView(
      viewModel: viewModel, completion: { self.handleImportFlowViewAction($0) })

    steps.append(.dashFlow(view))
  }

  private func showKeychainImport() {
    let viewModel = sessionServices.makeKeychainImportFlowViewModel(
      applicationDatabase: sessionServices.database)
    let view = ImportFlowView(
      viewModel: viewModel, completion: { self.handleImportFlowViewAction($0) })

    steps.append(.keychainFlow(view))
  }
}

extension ImportMethodFlowViewModel {
  private func handleImportMethodViewAction(_ action: ImportMethodCompletion) {
    switch action {
    case .back:
      completion(.dismiss)
    case .skip:
      sessionServices.userSettings[.hasSkippedPasswordOnboarding] = true
      completion(.dismiss)
    case .methodSelected(let importMethod):
      methodSelected(importMethod)
    }
  }

  func handleImportFlowViewAction(_ action: ImportDismissAction) {
    switch action {
    case .popToRootView:
      steps.removeLast()
    case .dismiss:
      completion(.dismiss)
    }
  }
}
