import Combine
import CorePersonalData
import CorePremium
import CoreUserTracking
import Foundation
import SwiftTreats
import VaultKit
import NotificationKit
import CoreFeature

@MainActor
final class AddItemFlowViewModel: ObservableObject, SessionServicesInjecting, AutoFillDemoHandler, Identifiable {

    enum Completion {
        case dismiss
    }

    enum DisplayMode {
        case itemType(_ itemType: VaultItem.Type)
        case categoryDetail(_ category: ItemCategory)
        case prefilledPassword(_ password: GeneratedPassword)
    }

    enum Step {
        case addItem(items: [ItemCategory.Item], title: String)
        case addPrefilledCredential(AddPrefilledCredentialViewModel)
        case credentialDetail(CredentialDetailViewModel)
        case detail(ItemDetailViewType)
        case autofillDemoDummyFields(Credential)
    }

    let id = UUID()

        @Published
    var steps: [Step] = []

    @Published
    var showAutofillDemo: Bool = false

    @Published
    var autofillDemoDummyFieldsCredential: Credential?

    let completion: (Completion) -> Void

        private let actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never> = .init()

    private var cancellables: Set<AnyCancellable> = []

        let detailViewFactory: DetailView.Factory
    private let credentialDetailViewModelFactory: CredentialDetailViewModel.Factory
    private let addPrefilledCredentialViewModelFactory: AddPrefilledCredentialViewModel.Factory
    private let autofillOnboardingFlowViewModelFactory: AutofillOnboardingFlowViewModel.Factory

        private let activityReporter: ActivityReporterProtocol
    private let capabilityService: CapabilityServiceProtocol
    private let deeplinkService: DeepLinkingServiceProtocol

    init(
        displayMode: AddItemFlowViewModel.DisplayMode,
        completion: @escaping (AddItemFlowViewModel.Completion) -> Void,
        detailViewFactory: DetailView.Factory,
        credentialDetailViewModelFactory: CredentialDetailViewModel.Factory,
        addPrefilledCredentialViewModelFactory: AddPrefilledCredentialViewModel.Factory,
        autofillOnboardingFlowViewModelFactory: AutofillOnboardingFlowViewModel.Factory,
        sessionServices: SessionServicesContainer
    ) {
        self.completion = completion

        self.detailViewFactory = detailViewFactory
        self.credentialDetailViewModelFactory = credentialDetailViewModelFactory
        self.addPrefilledCredentialViewModelFactory = addPrefilledCredentialViewModelFactory
        self.autofillOnboardingFlowViewModelFactory = autofillOnboardingFlowViewModelFactory

        self.activityReporter = sessionServices.activityReporter
        self.capabilityService = sessionServices.premiumService
        self.deeplinkService = sessionServices.appServices.deepLinkingService

        registerHandlers()
        start(with: displayMode)
    }

    private func registerHandlers() {
        actionPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] action in
                switch action {
                case .showAutofillDemo(vaultItem: let item):
                    self?.showAutofillDemo(for: item)
                }
            }
            .store(in: &cancellables)
    }

    func start(with mode: DisplayMode) {
        switch mode {
        case .categoryDetail(let category):
            showDetailAddItemView(.category(category))
        case .itemType(let itemType):
            showDetailAddItemView(.itemType(itemType))
        case .prefilledPassword(let password):
            showAddCredential(using: password)
        }
    }
}

extension AddItemFlowViewModel {
    func handleAddItemViewAction(_ itemType: VaultItem.Type) {
        steps.append(.detail(.adding(itemType)))
    }

    func handleAutofillDemoDummyFieldsAction(_ action: AutoFillDemoDummyFields.Completion) {
        switch action {
        case .back:
            if Device.isIpadOrMac {
                autofillDemoDummyFieldsCredential = nil
            } else {
                steps.removeLast()
            }
        case .setupAutofill:
            showAutoFillDemo()
        }
    }
}

extension AddItemFlowViewModel {
    private func showDetailAddItemView(_ detail: DisplayMode.Detail) {
        guard let capability = detail.capability else {
            pushAddItemView(detail: detail)
            return
        }

        if case .needsUpgrade = capabilityService.state(of: capability) {
            deeplinkService.handleLink(.planPurchase(initialView: .paywall(key: capability)))
        } else {
            pushAddItemView(detail: detail)
        }
    }

    private func pushAddItemView(detail: DisplayMode.Detail) {
        switch detail {
        case let .category(category):
            steps.append(makeAddItemStep(category))
        case let .itemType(itemType):
            if itemType is Credential.Type {
                steps.append(makePrefilledCredentialStep())
            } else {
                steps.append(.detail(.adding(itemType)))
            }
        }
    }

    func makeAddItemStep(_ category: ItemCategory) -> Step {
        switch category {
        case .credentials:
            return makePrefilledCredentialStep()
        case .secureNotes:
            return .detail(.adding(SecureNote.self))
        default:
            return .addItem(items: category.items, title: category.addTitle)
        }
    }

    func makePrefilledCredentialStep() -> Step {
        let model = addPrefilledCredentialViewModelFactory.make { [weak self] credential, prefilled in
            guard let self else { return }
            let model = self.credentialDetailViewModelFactory.make(
                item: credential,
                mode: .adding(prefilled: prefilled),
                actionPublisher: self.actionPublisher
            )

            self.steps.append(.credentialDetail(model))
        }

        return .addPrefilledCredential(model)
    }

    func showAddCredential(using password: GeneratedPassword) {
        var credential = Credential()
        credential.password = password.password ?? ""
        let model = credentialDetailViewModelFactory.make(
            item: credential,
            mode: .adding(prefilled: false),
            generatedPasswordToLink: password
        )

        steps.removeAll()
        steps.append(.credentialDetail(model))
    }

    func showAutofillDemo(for credential: Credential) {
        showAutofillDemo(
            for: credential,
            modal: { self.autofillDemoDummyFieldsCredential = credential },
            push: { self.steps.append(.autofillDemoDummyFields(credential)) }
        )
    }

    func showAutoFillDemo() {
        showAutofillDemo = true
    }
}

extension AddItemFlowViewModel {
    func makeAutofillOnboardingFlowViewModel() -> AutofillOnboardingFlowViewModel {
        return autofillOnboardingFlowViewModelFactory.make(completion: { [weak self] in
            self?.completion(.dismiss)
        })
    }
}

private extension AddItemFlowViewModel.DisplayMode {
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
