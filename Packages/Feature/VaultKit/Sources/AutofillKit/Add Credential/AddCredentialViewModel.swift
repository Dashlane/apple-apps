import Foundation
import Combine
import CorePasswords
import CorePersonalData
import CoreSettings
import CoreUserTracking
import CorePremium
import CoreFeature
import CoreSession
import DashTypes
import DesignSystem
import IconLibrary
import VaultKit
import Logger
import CoreActivityLogs

@MainActor
public class AddCredentialViewModel: ObservableObject {
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

        var passwordStrength: TextFieldPasswordStrengthFeedback.Strength {
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
    let pasteboardService: PasteboardService
    let domainLibrary: DomainIconLibraryProtocol
    let visitedWebsite: String?
    let didFinish: (Credential) -> Void
    let userSettings: UserSettings
    let activityLogsService: ActivityLogsServiceProtocol
    private var emailsSubcription: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    public init(database: ApplicationDatabase,
                logger: Logger,
                session: Session,
                businessTeamsInfo: BusinessTeamsInfo?,
                personalDataURLDecoder: PersonalDataURLDecoderProtocol,
                pasteboardService: PasteboardService,
                passwordEvaluator: PasswordEvaluatorProtocol,
                activityReporter: ActivityReporterProtocol,
                domainLibrary: DomainIconLibraryProtocol,
                visitedWebsite: String?,
                userSettings: UserSettings,
                activityLogsService: ActivityLogsServiceProtocol,
                didFinish: @escaping (Credential) -> Void) {
        self.database = database
        self.passwordEvaluator = passwordEvaluator
        self.activityReporter = activityReporter
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
        self.preferences = userSettings[.passwordGeneratorPreferences] ?? PasswordGeneratorPreferences()
        self.item.editableURL = visitedWebsite ?? ""
        emailsSubcription = database
            .itemsPublisher(for: CorePersonalData.Email.self)
            .map { Array($0) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.emails, on: self)

        availableUserSpaces = [.personal]
        if let availableBusinessTeam = businessTeamsInfo?.availableBusinessTeam {
            let space = UserSpace.business(availableBusinessTeam)
            availableUserSpaces.append(space)
        }

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
            mode: .selection(item, { [weak self] generated in
                self?.item.password = generated.password ?? ""
            }),
            database: database,
            passwordEvaluator: passwordEvaluator,
            sessionActivityReporter: activityReporter,
            userSettings: userSettings,
            copyAction: { [weak self] password in
                self?.pasteboardService.set(password)
            })

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
            item.spaceId = selectedSpace.id
            if let domain = url.domain {
                item.title = domain.name.removingPercentEncoding ?? domain.name
            }
        }
    }

    func save() {
        let logItem = item
        activityReporter.report(UserEvent.UpdateVaultItem(action: .add,
                                                          itemId: logItem.userTrackingLogID,
                                                          itemType: .credential,
                                                          space: logItem.userTrackingSpace,
                                                          updateCredentialOrigin: .manual))

        activityReporter.report(AnonymousEvent.UpdateCredential(action: .add,
                                                                domain: logItem.hashedDomainForLogs(),
                                                                space: logItem.userTrackingSpace,
                                                                updateCredentialOrigin: .manual))

        activityReporter.report(UserEvent.AutofillAccept(dataTypeList: [.credential]))
        activityReporter.report(AnonymousEvent.AutofillAccept(domain: logItem.hashedDomainForLogs()))
        do {
            let savedItem = try database.save(item)
            item = savedItem
        } catch {
            logger.sublogger(for: AppLoggerIdentifier.personalData).error("Error on save", error: error)
        }
        guard let info = item.reportableInfo() else { return }
        try? activityLogsService.report(.creation, for: info)
    }
}

private extension PasswordStrength {
    var textFieldPasswordStrengthFeedbackStrength: TextFieldPasswordStrengthFeedback.Strength {
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
        guard hasSpaceSelection else {
            return
        }

        if let forcedSpace = forcedDomain(for: credential) {
            selectedSpace = forcedSpace
            spaceIsSwitchable = false
        } else {
            spaceIsSwitchable = true
        }
    }

    private func forcedDomain(for credential: Credential) -> UserSpace? {
        for space in availableUserSpaces {
            switch space {
            case .business(let businessTeam):
                if businessTeam.shouldForceSpace, businessTeam.shouldBeForced(on: credential) {
                    return space
                }
            default:
                break
            }
        }
        return nil
    }
}

extension AddCredentialViewModel {
    static func mock(existingItems: [PersonalDataCodable] = [], hasBusinessTeam: Bool = false) -> AddCredentialViewModel {
        let businessTeam =  BusinessTeam(space: Space(teamId: "teamId",
                                                             teamName: "Dashlane",
                                                             letter: "D",
                                                             color: "d22",
                                                             associatedEmail: "",
                                                             membersNumber: 1,
                                                             teamAdmins: [],
                                                             billingAdmins: [],
                                                             isTeamAdmin: false,
                                                             isBillingAdmin: false,
                                                             planType: "",
                                                             status: .accepted,
                                                             info: SpaceInfo()),
                                                anonymousTeamId: "d22")

        return AddCredentialViewModel(database: ApplicationDBStack.mock(items: existingItems),
                                      logger: LoggerMock(),
                                      session: .mock,
                                      businessTeamsInfo: hasBusinessTeam ? BusinessTeamsInfo(businessTeams: [businessTeam]) : nil,
                                      personalDataURLDecoder: PersonalDataURLDecoderMock(personalDataURL: nil),
                                      pasteboardService: PasteboardService.mock(),
                                      passwordEvaluator: .mock(),
                                      activityReporter: .fake,
                                      domainLibrary: FakeDomainIconLibrary(icon: nil),
                                      visitedWebsite: nil,
                                      userSettings: UserSettings.mock,
                                      activityLogsService: .mock(),
                                      didFinish: {_ in })
    }
}
