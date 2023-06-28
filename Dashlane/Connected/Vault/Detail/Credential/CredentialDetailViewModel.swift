import SwiftUI
import CorePersonalData
import CorePasswords
import DashTypes
import CoreSession
import Combine
import CorePremium
import CoreUserTracking
import DashlaneAppKit
import IconLibrary
import DocumentServices
import CoreSettings
import VaultKit
import AutofillKit
import CoreFeature
import UIComponents

class CredentialDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    @Published
    var navigationBarColor: SwiftUI.Color?

    @Published
    var reusedCount: Int?

    @Published
    var isCompromised: Bool = false

    var credentialsCount = PassthroughSubject<Int, Never>()

    var emailsSuggestions: [String] {
        return vaultItemsService.emails.map {
            $0.value
        }
        .sorted()
    }

    var addedDomains: [LinkedServices.AssociatedDomain] {
        return item.linkedServices.associatedDomains
    }

    var linkedDomains: [String] {
        guard let domain = item.url?.domain, let linkedDomains = linkedDomainsService[domain.name] else {
            return []
        }
        return linkedDomains
    }

    var linkedDomainsCount: Int {
        return linkedDomains.count + addedDomains.count
    }

    @Published
    var isAutoFillDemoModalShown: Bool = false

    @Published
    var isAdd2FAFlowPresented: Bool = false

    lazy var passwordHealthSectionModel: PasswordHealthSectionModel = passwordHealthSectionModelFactory.make(service: service)

    let credentialMainSectionModelFactory: CredentialMainSectionModel.Factory
    let passwordHealthSectionModelFactory: PasswordHealthSectionModel.Factory
    let passwordAccessorySectionModelFactory: PasswordAccessorySectionModel.Factory
    let notesSectionModelFactory: NotesSectionModel.Factory
    let sharingDetailSectionModelFactory: SharingDetailSectionModel.Factory
    let domainsSectionModelFactory: DomainsSectionModel.Factory
    let addOTPFlowViewModelFactory: AddOTPFlowViewModel.Factory

    let passwordGeneratorViewModelFactory: (PasswordGeneratorMode, @escaping (String) -> Void) -> PasswordGeneratorViewModel
    let origin: ItemDetailOrigin

    var wasAdding: Bool = false

    enum Action {
        case showAutofillDemo(vaultItem: Credential)
    }

    var actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>?
    var updatePublisher = PassthroughSubject<CredentialDetailViewModel.LinkedServicesUpdate, Never>()

    let service: DetailService<Credential>

        private var generatedPasswordToLink: GeneratedPassword?

    private let featureService: FeatureServiceProtocol
    private let passwordEvaluator: PasswordEvaluatorProtocol
    private var subscriptions = Set<AnyCancellable>()
    private let linkedDomainsService: LinkedDomainService
    private let onboardingService: OnboardingService
    private let autofillService: AutofillService
    private let domainIconLibrary: DomainIconLibraryProtocol
    private let didSaveCallback: (() -> Void)?
    private let vaultItemsServices: VaultItemsServiceProtocol
    private var iconTask: Task<Void, Error>?

    var vaultItemsService: VaultItemsServiceProtocol {
        service.vaultItemsService
    }

    private var activityReporter: ActivityReporterProtocol {
        service.activityReporter
    }

    enum LinkedServicesUpdate {
        case commit(addedDomains: LinkedServices)
        case save(addedDomains: LinkedServices)
    }

    convenience init(
        item: Credential,
        session: Session,
        mode: DetailMode = .viewing,
        generatedPasswordToLink: GeneratedPassword? = nil,
        vaultItemsService: VaultItemsServiceProtocol,
        actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil,
        origin: ItemDetailOrigin = ItemDetailOrigin.unknown,
        sharingService: SharedVaultHandling,
        teamSpacesService: TeamSpacesService,
        premiumService: PremiumServiceProtocol,
        iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
        deepLinkService: VaultKit.DeepLinkingServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        featureService: FeatureServiceProtocol,
        iconService: IconServiceProtocol,
        logger: Logger,
        accessControl: AccessControlProtocol,
        userSettings: UserSettings,
        passwordEvaluator: PasswordEvaluatorProtocol,
        linkedDomainsService: LinkedDomainService,
        onboardingService: OnboardingService,
        autofillService: AutofillService,
        documentStorageService: DocumentStorageService,
        pasteboardService: PasteboardServiceProtocol,
        didSave: (() -> Void)? = nil,
        credentialMainSectionModelFactory: CredentialMainSectionModel.Factory,
        passwordHealthSectionModelFactory: PasswordHealthSectionModel.Factory,
        passwordAccessorySectionModelFactory: PasswordAccessorySectionModel.Factory,
        notesSectionModelFactory: NotesSectionModel.Factory,
        sharingDetailSectionModelFactory: SharingDetailSectionModel.Factory,
        domainsSectionModelFactory: DomainsSectionModel.Factory,
        makePasswordGeneratorViewModel: PasswordGeneratorViewModel.Factory,
        addOTPFlowViewModelFactory: AddOTPFlowViewModel.Factory,
        passwordGeneratorViewModelFactory: @escaping (PasswordGeneratorMode, @escaping (String) -> Void) -> PasswordGeneratorViewModel,
        attachmentSectionFactory: AttachmentsSectionViewModel.Factory
    ) {
        self.init(
            generatedPasswordToLink: generatedPasswordToLink,
            vaultItemsService: vaultItemsService,
            actionPublisher: actionPublisher,
            featureService: featureService,
            iconService: iconService,
            passwordEvaluator: passwordEvaluator,
            linkedDomainsService: linkedDomainsService,
            onboardingService: onboardingService,
            autofillService: autofillService,
            didSave: didSave,
            credentialMainSectionModelFactory: credentialMainSectionModelFactory,
            passwordHealthSectionModelFactory: passwordHealthSectionModelFactory,
            passwordAccessorySectionModelFactory: passwordAccessorySectionModelFactory,
            notesSectionModelFactory: notesSectionModelFactory,
            sharingDetailSectionModelFactory: sharingDetailSectionModelFactory,
            domainsSectionModelFactory: domainsSectionModelFactory,
            addOTPFlowViewModelFactory: addOTPFlowViewModelFactory,
            passwordGeneratorViewModelFactory: passwordGeneratorViewModelFactory,
            service: .init(
                item: item,
                mode: mode,
                vaultItemsService: vaultItemsService,
                sharingService: sharingService,
                teamSpacesService: teamSpacesService,
                documentStorageService: documentStorageService,
                deepLinkService: deepLinkService,
                activityReporter: activityReporter,
                iconViewModelProvider: iconViewModelProvider,
                attachmentSectionFactory: attachmentSectionFactory,
                logger: logger,
                accessControl: accessControl,
                userSettings: userSettings,
                pasteboardService: pasteboardService
            )
        )
    }

    init(generatedPasswordToLink: GeneratedPassword? = nil,
         vaultItemsService: VaultItemsServiceProtocol,
         actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil,
         origin: ItemDetailOrigin = ItemDetailOrigin.unknown,
         featureService: FeatureServiceProtocol,
         iconService: IconServiceProtocol,
         passwordEvaluator: PasswordEvaluatorProtocol,
         linkedDomainsService: LinkedDomainService,
         onboardingService: OnboardingService,
         autofillService: AutofillService,
         didSave: (() -> Void)? = nil,
         credentialMainSectionModelFactory: CredentialMainSectionModel.Factory,
         passwordHealthSectionModelFactory: PasswordHealthSectionModel.Factory,
         passwordAccessorySectionModelFactory: PasswordAccessorySectionModel.Factory,
         notesSectionModelFactory: NotesSectionModel.Factory,
         sharingDetailSectionModelFactory: SharingDetailSectionModel.Factory,
         domainsSectionModelFactory: DomainsSectionModel.Factory,
         addOTPFlowViewModelFactory: AddOTPFlowViewModel.Factory,
         passwordGeneratorViewModelFactory: @escaping (PasswordGeneratorMode, @escaping (String) -> Void) -> PasswordGeneratorViewModel,
         service: DetailService<Credential>) {
        self.generatedPasswordToLink = generatedPasswordToLink
        self.passwordEvaluator = passwordEvaluator
        self.credentialMainSectionModelFactory = credentialMainSectionModelFactory
        self.passwordAccessorySectionModelFactory = passwordAccessorySectionModelFactory
        self.passwordHealthSectionModelFactory = passwordHealthSectionModelFactory
        self.notesSectionModelFactory = notesSectionModelFactory
        self.passwordGeneratorViewModelFactory = passwordGeneratorViewModelFactory
        self.sharingDetailSectionModelFactory = sharingDetailSectionModelFactory
        self.domainsSectionModelFactory = domainsSectionModelFactory
        self.addOTPFlowViewModelFactory = addOTPFlowViewModelFactory
        self.actionPublisher = actionPublisher
        self.featureService = featureService
        self.linkedDomainsService = linkedDomainsService
        self.onboardingService = onboardingService
        self.autofillService = autofillService
        self.vaultItemsServices = vaultItemsService
        self.domainIconLibrary = iconService.domain
        self.didSaveCallback = didSave
        self.origin = origin
        self.service = service

        registerServiceChanges()
        registerPublishers()
    }

    deinit {
        iconTask?.cancel()
    }

    private func registerServiceChanges() {
        service
            .objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &subscriptions)
    }

    private func registerPublishers() {
        vaultItemsServices.$credentials
            .map({ $0.count })
            .removeDuplicates()
            .sink { [weak self] count in
                self?.credentialsCount.send(count)
            }
            .store(in: &subscriptions)

        if origin == .adding && onboardingService.shouldShowAutofillDemo {
            suggestAutofillDemo()
        }

        iconTask = Task {
            let color = try await fetchNavigationBackgroundColor()
            await MainActor.run {
                self.navigationBarColor = color
            }
        }

        updatePublisher.receive(on: DispatchQueue.main).sink { [weak self] update in
            guard let self = self else {
                return
            }
            switch update {
            case .commit(let addedDomains):
                self.item.linkedServices = addedDomains
            case .save(let addedDomains):
                self.item.linkedServices = addedDomains
                self.save()
                self.eventPublisher.send(.domainsUpdate)
            }
        }.store(in: &subscriptions)
    }

    func prepareForSaving() throws {
        try service.prepareForSaving()
        if item.password != originalItem.password {
            item.passwordModificationDate = Date()
        }
        if mode.isAdding {
            self.wasAdding = true
        }
    }

    func save() {
        service.save()
        didSave()
    }

    func delete() async {
        await service.delete()
    }

    func showAutoFillDemo() {
        actionPublisher?.send(.showAutofillDemo(vaultItem: item))
    }

}

private extension CredentialDetailViewModel {
    func didSave() {
                if let generatedPassword = generatedPasswordToLink {
            _ = try? vaultItemsService.link(generatedPassword, to: item)
            generatedPasswordToLink = nil
        }
        suggestAutofillDemo()
        didSaveCallback?()
    }

    func suggestAutofillDemo() {
        guard UIDevice.current.userInterfaceIdiom != .pad, autofillService.activationStatus != .enabled, onboardingService.shouldShowAutofillDemo else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.activateAutofillDemo()
        }
    }

    func activateAutofillDemo() {
        onboardingService.hasSeenAutofillDemo()
        isAutoFillDemoModalShown = true
    }

    func fetchNavigationBackgroundColor() async throws -> SwiftUI.Color? {
        let icon = try await domainIconLibrary.icon(for: item, usingLargeImage: false)
        guard let color = icon?.colors?.fallbackColor else {
            return nil
        }
        return SwiftUI.Color(color)
    }
}

extension CredentialDetailViewModel {
    func makeAddOTPFlowViewModel() -> AddOTPFlowViewModel {
                                let previousMode = mode
        mode = .viewing
        return addOTPFlowViewModelFactory.make(mode: .credentialPrefilled(item)) { [weak self] in
            self?.mode = previousMode
        }
    }

    func makePasswordGeneratorViewModel() -> PasswordGeneratorViewModel {
        return passwordGeneratorViewModelFactory(.selection(item, { [weak self] generated in
            guard let self = self else {
                return
            }
            self.item.password = generated.password ?? ""
            self.generatedPasswordToLink = generated
        }), { password in
            PasteboardService(userSettings: self.service.userSettings).set(password)
        })
    }

    func makeDomainsViewModel(from additionMode: Bool = false) -> CredentialDomainsViewModel {
        CredentialDomainsViewModel(item: item,
                                   isAdditionMode: additionMode,
                                   initialMode: mode,
                                   vaultItemsServices: vaultItemsServices,
                                   activityReporter: activityReporter,
                                   linkedDomainsService: linkedDomainsService,
                                   updatePublisher: updatePublisher)
    }
}
