import SwiftUI
import CorePersonalData
import CorePasswords
import DashTypes
import CoreSession
import Combine
import CorePremium
import DashlaneReportKit
import CoreUserTracking
import DashlaneAppKit
import IconLibrary
import DocumentServices
import CoreSettings
import VaultKit
import CoreFeature

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

    let passwordGeneratorViewModelFactory: (PasswordGeneratorMode) -> PasswordGeneratorViewModel
    let logger: CredentialDetailUsageLogger
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
    private let passwordEvaluator: PasswordEvaluator
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

    init(
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
        vaultItemsServices: VaultItemsServiceProtocol,
        iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
        usageLogService: UsageLogServiceProtocol,
        deepLinkService: DeepLinkingServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        featureService: FeatureServiceProtocol,
        iconService: IconServiceProtocol,
        logger: Logger,
        accessControl: AccessControlProtocol,
        userSettings: UserSettings,
        passwordEvaluator: PasswordEvaluator,
        linkedDomainsService: LinkedDomainService,
        onboardingService: OnboardingService,
        autofillService: AutofillService,
        documentStorageService: DocumentStorageService,
        didSave: (() -> Void)? = nil,
        credentialMainSectionModelFactory: CredentialMainSectionModel.Factory,
        passwordHealthSectionModelFactory: PasswordHealthSectionModel.Factory,
        passwordAccessorySectionModelFactory: PasswordAccessorySectionModel.Factory,
        notesSectionModelFactory: NotesSectionModel.Factory,
        sharingDetailSectionModelFactory: SharingDetailSectionModel.Factory,
        domainsSectionModelFactory: DomainsSectionModel.Factory,
        makePasswordGeneratorViewModel: PasswordGeneratorViewModel.Factory,
        addOTPFlowViewModelFactory: AddOTPFlowViewModel.Factory,
        passwordGeneratorViewModelFactory: @escaping (PasswordGeneratorMode) -> PasswordGeneratorViewModel,
        attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
        attachmentsListViewModelProvider: @escaping (VaultItem, AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel
    ) {
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
        self.logger = CredentialDetailUsageLogger(usageLogService: usageLogService, item: item)
        self.actionPublisher = actionPublisher
        self.featureService = featureService
        self.linkedDomainsService = linkedDomainsService
        self.onboardingService = onboardingService
        self.autofillService = autofillService
        self.vaultItemsServices = vaultItemsServices
        self.domainIconLibrary = iconService.domain
        self.didSaveCallback = didSave
        self.origin = origin
        self.service = .init(
            item: item,
            mode: mode,
            vaultItemsService: vaultItemsService,
            sharingService: sharingService,
            teamSpacesService: teamSpacesService,
            usageLogService: usageLogService,
            documentStorageService: documentStorageService,
            deepLinkService: deepLinkService,
            activityReporter: activityReporter,
            iconViewModelProvider: iconViewModelProvider,
            logger: logger,
            accessControl: accessControl,
            userSettings: userSettings,
            attachmentSectionFactory: attachmentSectionFactory,
            attachmentsListViewModelProvider: attachmentsListViewModelProvider
        )

        registerServiceChanges()
        registerPublishers()
    }

    deinit {
        iconTask?.cancel()
    }

    private func registerServiceChanges() {
        service
            .objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &subscriptions)
    }

    private func registerPublishers() {
        vaultItemsService.$credentials
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
                self.display(message: L10n.Localizable.KWAuthentifiantIOS.Domains.update)
            }
        }.store(in: &subscriptions)
    }

    func prepareForSaving() throws {
        try service.prepareForSaving()
        if item.password != originalItem.password {
            item.passwordModificationDate = Date()
        }
        logPasswordDetails()
        if mode.isAdding {
            self.wasAdding = true
            guard let url = item.url else { return }
            logger.logSavePassword(credentialsCount: vaultItemsService.credentials.count, url: url)
        }
    }

    func save() {
        service.save()
        didSave()
    }

    func delete() async {
        await service.delete()
        logPasswordDetails(isDeleting: true)
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
        addOTPFlowViewModelFactory.make(mode: .credentialPrefilled(item)) { [weak self] in
            self?.save()
        }
    }

    func makePasswordGeneratorViewModel() -> PasswordGeneratorViewModel {
        return passwordGeneratorViewModelFactory(.selection(item, { [weak self] generated in
            guard let self = self else {
                return
            }
            self.item.password = generated.password ?? ""
            self.generatedPasswordToLink = generated
        }))
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
