import Foundation
import Combine
import SwiftUI
import NotificationKit
import CoreFeature

struct GenericSheet: Identifiable {
    let id = UUID()
    let view: AnyView

    init(view: some View) {
        self.view = view.eraseToAnyView()
    }
}

@MainActor
protocol OnboardingChecklistActionHandler: AnyObject {
    var genericSheet: GenericSheet? { get set }
    var genericFullCover: GenericSheet? { get set }

    var sessionServices: SessionServicesContainer { get }
    func handleOnboardingChecklistViewAction(_ action: OnboardingChecklistFlowViewModel.Action)
    func dismissOnboardingChecklistFlow()
}

@MainActor
extension OnboardingChecklistActionHandler {
    func handleOnboardingChecklistViewAction(_ action: OnboardingChecklistFlowViewModel.Action) {
        switch action {
        case let .addNewItem(displayMode):
            addNewItem(displayMode: displayMode)
        case let .ctaTapped(action):
            ctaTapped(for: action)
        case .onDismiss:
            dismissOnboardingChecklistFlow()
        default: break
        }
    }

    func presentSheet(_ sheet: GenericSheet) {
        genericSheet = sheet
    }

    func presentFullCover(_ cover: GenericSheet) {
        genericFullCover = cover
    }

    func dismissSheet() {
        genericSheet = nil
    }

    func dismissFullCover() {
        genericFullCover = nil
    }

    private func presentSheet(_ view: some View) {
        presentSheet(GenericSheet(view: view.eraseToAnyView()))
    }

    private func presentFullCover(_ view: some View) {
        presentFullCover(GenericSheet(view: view.eraseToAnyView()))
    }

    func addNewItem(displayMode: AddItemFlowViewModel.DisplayMode) {
        let viewModel = sessionServices.makeAddItemFlowViewModel(displayMode: displayMode) { [weak self] _ in
            self?.dismissFullCover()
        }
        presentFullCover(
            NavigationView {
                AddItemFlow(viewModel: viewModel)
            }
        )
    }

    func ctaTapped(for action: OnboardingChecklistAction) {
        switch action {
        case .addFirstPasswordsManually:
            startImportMethodFlow(mode: .firstPassword)
        case .importFromBrowser:
            startImportMethodFlow(mode: .browser)
        case .fixBreachedAccounts:
            showDarkWebMonitoring()
        case .seeScanResult:
            let settingsProvider = GuidedOnboardingSettingsProvider(userSettings: sessionServices.spiegelUserSettings)

            if let selectedAnswer = settingsProvider.storedAnswers[.howPasswordsHandled] {
                switch selectedAnswer {
                case .memorizePasswords, .somethingElse:
                    return startImportMethodFlow(mode: .firstPassword)
                case .browser:
                    return startImportMethodFlow(mode: .browser)
                default:
                    assertionFailure("Unacceptable answer")
                }
            }
        case .activateAutofill:
            Task { @MainActor in
                let model = sessionServices.viewModelFactory.makeAutofillOnboardingFlowViewModel { [weak self] in
                    self?.dismissSheet()
                }
                self.presentSheet(AutofillOnboardingFlowView(model: model))
            }
        case .m2d:
            let settings = M2WSettings(userSettings: sessionServices.spiegelUserSettings)
            let viewModel = M2WFlowViewModel(initialStep: .connect)
            let view = M2WFlowView(viewModel: viewModel) { [weak self] dismissAction in
                switch dismissAction {
                case .success:
                    settings.setUserHasFinishedM2W()
                    fallthrough
                default:
                    self?.dismissSheet()
                }
            }
            presentSheet(view)
        }
    }

    private func startImportMethodFlow(mode: ImportMethodMode) {
        let viewModel = sessionServices.makeImportMethodFlowViewModel(mode: mode) { [weak self] completion in
            switch completion {
            case .dismiss:
                self?.genericFullCover = nil
            }
        }
        presentFullCover(
            NavigationView {
                ImportMethodFlow(viewModel: viewModel)
            }
        )
    }

    private func showDarkWebMonitoring() {
        sessionServices.appServices.deepLinkingService.handleLink(.tool(.darkWebMonitoring))
    }
}
