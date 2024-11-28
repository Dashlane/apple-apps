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
import DesignSystem
import Foundation
import IconLibrary
import Logger
import VaultKit

@MainActor
public class AddCredentialViewModel: ObservableObject {

  enum Step {
    case root
    case passwordGenerator
    case confirmation
  }

  @Published var steps: [Step] = [.root]

  @Published
  var item: Credential
  @Published
  public var shouldReveal: Bool = true
  @Published
  var login: String = ""
  @Published
  var loginIsMail: Bool = false
  @Published
  var emails: [CorePersonalData.Email] = [] {
    didSet {
      guard let firstMail = emails.first else {
        login = session.login.email
        return
      }
      login = firstMail.value
    }
  }
  @Published
  var availableUserSpaces: [UserSpace] = []
  @Published
  var selectedSpace: UserSpace
  @Published
  var spaceIsSwitchable: Bool = true

  var passwordStrength: TextInputPasswordStrengthFeedback.Strength {
    passwordEvaluator.evaluate(item.password).textFieldPasswordStrengthFeedbackStrength
  }
  var hasSpaceSelection: Bool {
    availableUserSpaces.count > 1
  }
  @Published
  public var preferences: PasswordGeneratorPreferences

  let activityReporter: ActivityReporterProtocol
  let passwordEvaluator: PasswordEvaluatorProtocol
  let database: ApplicationDatabase
  let logger: Logger
  let session: Session
  let personalDataURLDecoder: PersonalDataURLDecoderProtocol
  let pasteboardService: PasteboardServiceProtocol
  let domainLibrary: DomainIconLibraryProtocol
  let visitedWebsite: String?
  let didFinish: (Credential) -> Void
  let userSettings: UserSettings
  let vaultStateService: VaultStateServiceProtocol
  let deeplinkingService: DeepLinkingServiceProtocol
  let activityLogsService: ActivityLogsServiceProtocol
  let sessionActivityReporter: ActivityReporterProtocol
  let userSpacesService: UserSpacesService
  let autofillService: AutofillService
  private var emailsSubcription: AnyCancellable?
  private var cancellables = Set<AnyCancellable>()

  public init(
    database: ApplicationDatabase,
    logger: Logger,
    session: Session,
    userSpacesService: UserSpacesService,
    personalDataURLDecoder: PersonalDataURLDecoderProtocol,
    pasteboardService: PasteboardServiceProtocol,
    passwordEvaluator: PasswordEvaluatorProtocol,
    activityReporter: ActivityReporterProtocol,
    vaultStateService: VaultStateServiceProtocol,
    deeplinkingService: DeepLinkingServiceProtocol,
    domainLibrary: DomainIconLibraryProtocol,
    visitedWebsite: String?,
    userSettings: UserSettings,
    activityLogsService: ActivityLogsServiceProtocol,
    sessionActivityReporter: ActivityReporterProtocol,
    autofillService: AutofillService,
    didFinish: @escaping (Credential) -> Void
  ) {
    self.database = database
    self.passwordEvaluator = passwordEvaluator
    self.activityReporter = activityReporter
    self.vaultStateService = vaultStateService
    self.deeplinkingService = deeplinkingService
    self.logger = logger
    self.session = session
    self.activityLogsService = activityLogsService
    self.personalDataURLDecoder = personalDataURLDecoder
    self.pasteboardService = pasteboardService
    self.didFinish = didFinish
    self.visitedWebsite = visitedWebsite
    self.domainLibrary = domainLibrary
    self.userSettings = userSettings
    self.item = Credential()
    self.selectedSpace = .personal
    self.sessionActivityReporter = sessionActivityReporter
    self.autofillService = autofillService
    self.preferences = userSettings[.passwordGeneratorPreferences] ?? PasswordGeneratorPreferences()
    self.userSpacesService = userSpacesService
    self.item.editableURL = visitedWebsite ?? ""

    emailsSubcription =
      database
      .itemsPublisher(for: CorePersonalData.Email.self)
      .map { Array($0) }
      .receive(on: DispatchQueue.main)
      .assign(to: \.emails, on: self)

    availableUserSpaces = userSpacesService.configuration.availableSpaces.filter { $0 != .both }

    $item
      .removeDuplicates()
      .sink { [weak self] credential in
        self?.checkForcedCategorization(for: credential)
      }
      .store(in: &cancellables)

    $login
      .removeDuplicates()
      .sink { [weak self] login in
        if let strongSelf = self {
          strongSelf.loginIsMail = Email(login).isValid
          if strongSelf.loginIsMail {
            strongSelf.item.email = login
            strongSelf.item.login = ""
          } else {
            strongSelf.item.email = ""
            strongSelf.item.login = login
          }
        }
      }
      .store(in: &cancellables)

    refreshPassword()
  }

  func makePasswordGeneratorViewModel() -> PasswordGeneratorViewModel {
    let passwordGeneratorViewModel = PasswordGeneratorViewModel(
      mode: .selection(
        item,
        { [weak self] generated in
          self?.item.password = generated.password ?? ""
        }),
      database: database,
      passwordEvaluator: passwordEvaluator,
      sessionActivityReporter: activityReporter,
      userSettings: userSettings,
      vaultStateService: vaultStateService,
      deeplinkingService: deeplinkingService,
      pasteboardService: pasteboardService
    )

    passwordGeneratorViewModel
      .$preferences
      .removeDuplicates()
      .sink { [weak self] passwordGeneratorPreferences in
        self?.preferences = passwordGeneratorPreferences
      }.store(in: &cancellables)

    return passwordGeneratorViewModel
  }

  func refreshPassword() {
    item.password = PasswordGenerator(preferences: preferences).generate()
  }

  func prepareForSaving() {
    if let url = try? personalDataURLDecoder.decodeURL(item.editableURL) {
      item.url = url
      item.spaceId = selectedSpace.personalDataId
      if let domain = url.domain {
        item.title = domain.name.removingPercentEncoding ?? domain.name
      }
    }
  }

  func save() async {
    let logItem = item
    activityReporter.report(
      UserEvent.UpdateVaultItem(
        action: .add,
        itemId: logItem.userTrackingLogID,
        itemType: .credential,
        space: logItem.userTrackingSpace,
        updateCredentialOrigin: .manual))

    activityReporter.report(
      AnonymousEvent.UpdateCredential(
        action: .add,
        domain: logItem.hashedDomainForLogs(),
        space: logItem.userTrackingSpace,
        updateCredentialOrigin: .manual))

    activityReporter.report(UserEvent.AutofillAccept(dataTypeList: [.credential]))
    activityReporter.report(AnonymousEvent.AutofillAccept(domain: logItem.hashedDomainForLogs()))

    do {
      checkForcedCategorization(for: item)
      let savedCredential = try database.save(item)
      await autofillService.save(savedCredential, oldCredential: nil)
      item = savedCredential
    } catch {
      logger.sublogger(for: AppLoggerIdentifier.personalData).error("Error on save", error: error)
    }

    guard let info = item.reportableInfo() else { return }
    try? activityLogsService.report(.creation, for: info)
  }
}

extension PasswordStrength {
  fileprivate var textFieldPasswordStrengthFeedbackStrength:
    TextInputPasswordStrengthFeedback.Strength
  {
    switch self {
    case .tooGuessable:
      return .weakest
    case .veryGuessable:
      return .weak
    case .somewhatGuessable:
      return .acceptable
    case .safelyUnguessable:
      return .good
    case .veryUnguessable:
      return .strong
    }
  }
}

extension AddCredentialViewModel {
  func checkForcedCategorization(for credential: Credential) {
    guard userSpacesService.configuration.canSelectSpace(for: item) else {
      selectedSpace = userSpacesService.configuration.defaultSpace(for: credential)
      spaceIsSwitchable = false
      return
    }
    spaceIsSwitchable = true
  }
}

extension AddCredentialViewModel {
  static func mock(existingItems: [PersonalDataCodable] = [], hasBusinessTeam: Bool = false)
    -> AddCredentialViewModel
  {

    return AddCredentialViewModel(
      database: ApplicationDBStack.mock(items: existingItems),
      logger: LoggerMock(),
      session: .mock,
      userSpacesService: .mock(status: hasBusinessTeam ? .Mock.team : .Mock.premiumWithAutoRenew),
      personalDataURLDecoder: PersonalDataURLDecoderMock(personalDataURL: nil),
      pasteboardService: PasteboardService.mock(),
      passwordEvaluator: .mock(),
      activityReporter: .mock,
      vaultStateService: .mock,
      deeplinkingService: MockVaultKitServicesContainer().deeplinkService,
      domainLibrary: FakeDomainIconLibrary(icon: nil),
      visitedWebsite: nil,
      userSettings: UserSettings.mock,
      activityLogsService: .mock(),
      sessionActivityReporter: .mock,
      autofillService: .fakeService,
      didFinish: { _ in })
  }
}
