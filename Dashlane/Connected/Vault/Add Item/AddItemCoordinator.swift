import Foundation
import CorePersonalData
import SwiftUI
import Combine
import CorePremium
import DashlaneAppKit
import SwiftTreats
import VaultKit
import NotificationKit
import CoreFeature

class AddItemCoordinator: Coordinator, SubcoordinatorOwner {
    enum DisplayMode {
        case itemType(_ itemType: VaultItem.Type)
        case categoryDetail(_ category: ItemCategory)
        case prefilledPassword(password: GeneratedPassword)
    }

    private var canGoBack: Bool {
        return self.navigator.viewControllers.count > 1
    }

    let displayMode: DisplayMode
    let navigator: DashlaneNavigationController
    let sessionServices: SessionServicesContainer
    let completion: () -> Void
    lazy var detailFactory = DetailViewFactory(sessionServices: sessionServices)
    var subcoordinator: Coordinator?
    private let actionPublisher = PassthroughSubject<CredentialDetailViewModel.Action, Never>()
    private var cancellables = Set<AnyCancellable>()

    init(sessionServices: SessionServicesContainer,
         displayMode: DisplayMode,
         navigator: DashlaneNavigationController? = nil,
         completion: @escaping () -> Void) {
        self.navigator = navigator ?? DashlaneNavigationController()
        self.navigator.modalPresentationStyle = Device.isIpadOrMac ? .formSheet : .fullScreen
        self.navigator.isModalInPresentation = true
        self.sessionServices = sessionServices
        self.displayMode = displayMode
        self.completion = completion

        actionPublisher.receive(on: RunLoop.main).sink { [weak self] action in
            guard let self = self else { return }
            switch action {
                case .showAutofillDemo(vaultItem: let item):
                    self.showAutofillDemo(for: item)
            }
        }.store(in: &cancellables)
    }

    func start() {
        switch displayMode {
        case .categoryDetail(let category):
            showDetailAddItemView(.category(category))
        case .itemType(let itemType):
            showDetailAddItemView(.itemType(itemType))
        case .prefilledPassword(let password):
            showAddCredential(using: password)
        }
    }

    private func showDetailAddItemView(_ detail: DisplayMode.Detail) {
        sessionServices.activityReporter.legacyUsage.addItemLogger.logTapAddItem()

        guard let capability = detail.capability else {
            pushAddItemView(detail: detail)
            return
        }

        if case .needsUpgrade = sessionServices.capabilityService.state(of: capability) {
            let deeplinkService = sessionServices.appServices.deepLinkingService
            deeplinkService.handleLink(.planPurchase(initialView: .paywall(key: capability)))
        } else {
            pushAddItemView(detail: detail)
        }
    }

    private func pushAddItemView(detail: DisplayMode.Detail) {
        switch detail {
        case let .category(category):
            let view = makeAddItemView(category)
            let barStyle: NavigationBarStyle = category == .secureNotes
                ? .hidden(statusBarStyle: .lightContent)
                : .default()
            self.navigator.push(view, barStyle: barStyle, animated: true)
        case let .itemType(itemType):
            if itemType is Credential.Type {
                self.navigator.push(makePrefilledCredentialView(), barStyle: .default(), animated: true)
            } else {
                self.navigator.push(self.detailFactory.view(for: .adding(itemType)),
                                    barStyle: .hidden(statusBarStyle: .lightContent),
                                    animated: true)
            }
        }
    }

    @ViewBuilder
    private func makeAddItemView(_ category: ItemCategory) -> some View {
        switch category {
        case .credentials:
            makePrefilledCredentialView()
        case .secureNotes:
            detailFactory.view(for: .adding(SecureNote.self))
        default:
            AddItemView(items: category.items, title: category.addTitle) { [weak self] itemType in
                guard let self = self else {
                    return
                }
                self.navigator.push(self.detailFactory.view(for: .adding(itemType)),
                                    barStyle: .hidden(statusBarStyle: .lightContent),
                                    animated: true)
            }
        }
    }

    @ViewBuilder
    private func makePrefilledCredentialView() -> some View {
        let model = sessionServices
            .viewModelFactory
            .makeAddPrefilledCredentialViewModel { [weak self] credential, prefilled in
                guard let self = self else {
                    return
                }
                let model = self.sessionServices
                    .viewModelFactory
                    .makeCredentialDetailViewModel(item: credential,
                                                   mode: .adding(prefilled: prefilled),
                                                   actionPublisher: self.actionPublisher)

                let view = CredentialDetailView(model: model).eraseToAnyView()
                self.navigator.push(view, barStyle: .hidden(statusBarStyle: .lightContent), animated: true)
            }
        AddPrefilledCredentialView(model: model)
    }

    private func dismissAddItemFlow() {
        self.navigator.dismiss(animated: true)
        completion()
    }

    private func popAddItemView() {
        self.navigator.pop(animated: true)
    }

    private func showAddCredential(using password: GeneratedPassword) {
        var credential = Credential()
        credential.password = password.password ?? ""
        let model = self.sessionServices
            .viewModelFactory
            .makeCredentialDetailViewModel(item: credential,
                                           mode: .adding(prefilled: false),
                                           generatedPasswordToLink: password)
        let view = CredentialDetailView(model: model).eraseToAnyView()
        self.navigator.setRootNavigation(view, barStyle: .hidden(statusBarStyle: .lightContent), animated: true)
    }

    private func showAutofillDemo(for credential: Credential) {
        subcoordinator = AutoFillDemoCoordinator(credential: credential, navigator: navigator) { [weak self] result in
            switch result {
            case .back:
                self?.navigator.dismiss(animated: true)
            case .setupAutofill:
                self?.showAutoFillOnboarding()
            }

        }
        subcoordinator?.start()
    }

    private func showAutoFillOnboarding() {
        Task { @MainActor in
            let model = sessionServices.viewModelFactory.makeAutofillOnboardingFlowViewModel(completion: { [weak self] in
                self?.navigator.dismiss(animated: true)
            })
            let view = AutofillOnboardingFlowView(model: model)
            _ = self.navigator.present(view, barStyle: .hidden(), animated: true)
        }
    }
}

private extension AddItemCoordinator.DisplayMode {
    enum Detail {
        case category(_ category: ItemCategory)
        case itemType(_ itemType: VaultItem.Type)

        var capability: CapabilityKey? {
            switch self {
            case let .category(category):
                return category.capabilityToBeCheckedForPaywall
            case let .itemType(itemType):
                switch itemType {
                case is Credential.Type:
                    return nil
                case is SecureNote.Type:
                    return .secureNotes
                default:
                    return nil
                }
            }
        }
    }
}

private extension ItemCategory {
    var capabilityToBeCheckedForPaywall: CapabilityKey? {
        switch self {
        case .credentials:
            return nil
        case .secureNotes:
            return .secureNotes
        default:
            return nil
        }
    }
}
