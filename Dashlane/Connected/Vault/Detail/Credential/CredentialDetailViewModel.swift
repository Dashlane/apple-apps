import AutofillKit
import Combine
import CoreActivityLogs
import CoreFeature
import CorePasswords
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import DocumentServices
import IconLibrary
import SwiftUI
import UIComponents
import VaultKit

@MainActor
class CredentialDetailViewModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  @Published
  var navigationBarColor: SwiftUI.Color?

  @Published
  var reusedCount: Int?

  @Published
  var isCompromised: Bool = false

  var credentialsCount = PassthroughSubject<Int, Never>()

  var emailsSuggestions: [String] {
    return vaultItemsStore.emails.map {
      $0.value
    }
    .sorted()
  }

  var addedDomains: [LinkedServices.AssociatedDomain] {
    return item.linkedServices.associatedDomains
  }

  var linkedDomains: [String] {
    return item.url?.domain?.linkedDomains ?? []
  }

  var linkedDomainsCount: Int {
    return linkedDomains.count + addedDomains.count
  }

  @Published
  var isAutoFillDemoModalShown: Bool = false

  @Published
  var isAdd2FAFlowPresented: Bool = false

  lazy var passwordHealthSectionModel: PasswordHealthSectionModel =
    passwordHealthSectionModelFactory.make(service: service)

  let credentialMainSectionModelFactory: CredentialMainSectionModel.Factory
  let passwordHealthSectionModelFactory: PasswordHealthSectionModel.Factory
  let passwordAccessorySectionModelFactory: PasswordAccessorySectionModel.Factory
  let notesSectionModelFactory: NotesSectionModel.Factory
  let sharingDetailSectionModelFactory: SharingDetailSectionModel.Factory
  let domainsSectionModelFactory: DomainsSectionModel.Factory
  let addOTPFlowViewModelFactory: AddOTPFlowViewModel.Factory
  let passwordGeneratorViewModelFactory: PasswordGeneratorViewModel.SecondFactory
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
  private let onboardingService: OnboardingService
  private let autofillService: AutofillService
  private let domainIconLibrary: DomainIconLibraryProtocol
  private let didSaveCallback: (() -> Void)?
  private var iconTask: Task<Void, Error>?

  var vaultItemsStore: VaultItemsStore {
    service.vaultItemsStore
  }

  var vaultItemDatabase: VaultItemDatabaseProtocol {
    service.vaultItemDatabase
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
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultStateService: VaultStateServiceProtocol,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil,
    origin: ItemDetailOrigin = ItemDetailOrigin.unknown,
    sharingService: SharedVaultHandling,
    userSpacesService: UserSpacesService,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    deepLinkService: VaultKit.DeepLinkingServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
    featureService: FeatureServiceProtocol,
    iconService: IconServiceProtocol,
    logger: Logger,
    userSettings: UserSettings,
    passwordEvaluator: PasswordEvaluatorProtocol,
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
    passwordGeneratorViewModelFactory: PasswordGeneratorViewModel.SecondFactory,
    attachmentSectionFactory: AttachmentsSectionViewModel.Factory
  ) {
    self.init(
      generatedPasswordToLink: generatedPasswordToLink,
      actionPublisher: actionPublisher,
      featureService: featureService,
      iconService: iconService,
      passwordEvaluator: passwordEvaluator,
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
        canLock: session.authenticationMethod.supportsLock,
        mode: mode,
        vaultItemDatabase: vaultItemDatabase,
        vaultItemsStore: vaultItemsStore,
        vaultStateService: vaultStateService,
        vaultCollectionDatabase: vaultCollectionDatabase,
        vaultCollectionsStore: vaultCollectionsStore,
        sharingService: sharingService,
        userSpacesService: userSpacesService,
        documentStorageService: documentStorageService,
        deepLinkService: deepLinkService,
        activityReporter: activityReporter,
        activityLogsService: activityLogsService,
        iconViewModelProvider: iconViewModelProvider,
        attachmentSectionFactory: attachmentSectionFactory,
        logger: logger,
        userSettings: userSettings,
        pasteboardService: pasteboardService
      )
    )
  }

  init(
    generatedPasswordToLink: GeneratedPassword? = nil,
    actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil,
    origin: ItemDetailOrigin = ItemDetailOrigin.unknown,
    featureService: FeatureServiceProtocol,
    iconService: IconServiceProtocol,
    passwordEvaluator: PasswordEvaluatorProtocol,
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
    passwordGeneratorViewModelFactory: PasswordGeneratorViewModel.SecondFactory,
    service: DetailService<Credential>
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
    self.actionPublisher = actionPublisher
    self.featureService = featureService
    self.onboardingService = onboardingService
    self.autofillService = autofillService
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
    vaultItemsStore.$credentials
      .map({ $0.count })
      .removeDuplicates()
      .sink { [weak self] count in self?.credentialsCount.send(count) }
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
        Task {
          await self.save()
        }
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

  func save() async {
    await service.save()
    didSave()
  }

  func delete() async {
    await service.delete()
  }

  func showAutoFillDemo() {
    actionPublisher?.send(.showAutofillDemo(vaultItem: item))
  }

}

extension CredentialDetailViewModel {
  fileprivate func didSave() {
    if let generatedPassword = generatedPasswordToLink {
      _ = try? vaultItemDatabase.link(generatedPassword, to: item)
      generatedPasswordToLink = nil
    }
    suggestAutofillDemo()
    didSaveCallback?()
  }

  fileprivate func suggestAutofillDemo() {
    guard UIDevice.current.userInterfaceIdiom != .pad, autofillService.activationStatus != .enabled,
      onboardingService.shouldShowAutofillDemo
    else {
      return
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.activateAutofillDemo()
    }
  }

  fileprivate func activateAutofillDemo() {
    onboardingService.hasSeenAutofillDemo()
    isAutoFillDemoModalShown = true
  }

  fileprivate func fetchNavigationBackgroundColor() async throws -> SwiftUI.Color? {
    let icon = try await domainIconLibrary.icon(for: item)
    guard let color = icon?.color else {
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
    return passwordGeneratorViewModelFactory.make(
      mode: .selection(
        item,
        { [weak self] generated in
          guard let self = self else {
            return
          }
          self.item.password = generated.password ?? ""
          self.generatedPasswordToLink = generated
        }))
  }

  func makeDomainsViewModel(from additionMode: Bool = false) -> CredentialDomainsViewModel {
    CredentialDomainsViewModel(
      item: item,
      isAdditionMode: additionMode,
      initialMode: mode,
      isFrozen: service.isFrozen,
      vaultItemsStore: vaultItemsStore,
      activityReporter: activityReporter,
      updatePublisher: updatePublisher)
  }
}
