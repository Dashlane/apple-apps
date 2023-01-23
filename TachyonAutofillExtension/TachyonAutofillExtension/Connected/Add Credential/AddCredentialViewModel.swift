import Foundation
import Combine
import CorePersonalData
import CorePasswords
import DashTypes
import Logger
import DashlaneAppKit
import CoreUserTracking
import IconLibrary
import CoreSettings
import VaultKit


@MainActor
class AddCredentialViewModel: ObservableObject {
    @Published
    var item: Credential
    @Published
    var shouldReveal: Bool = true
    @Published
    var emails: [CorePersonalData.Email] = []

    var passwordStrength: PasswordStrength {
        passwordEvaluator.evaluate(item.password).strength
    }

    let activityReporter: ActivityReporterProtocol
    let passwordEvaluator: PasswordEvaluator
    let usageLogService: UsageLogServiceProtocol
    let database: ApplicationDatabase
    let logger: Logger
    let personalDataURLDecoder: DashlaneAppKit.PersonalDataURLDecoder
    let domainLibrary: DomainIconLibrary
    let visitedWebsite: String?
    let didFinish: (Credential) -> Void
    let userSettings: UserSettings
    private var emailsSubcription: AnyCancellable?

    init(database: ApplicationDatabase,
         logger: Logger,
         personalDataURLDecoder: DashlaneAppKit.PersonalDataURLDecoder,
         passwordEvaluator: PasswordEvaluator,
         usageLogService: UsageLogServiceProtocol,
         activityReporter: ActivityReporterProtocol,
         domainLibrary: DomainIconLibrary,
         visitedWebsite: String?,
         userSettings: UserSettings,
         didFinish: @escaping (Credential) -> Void) {
        self.usageLogService = usageLogService
        self.database = database
        self.passwordEvaluator = passwordEvaluator
        self.activityReporter = activityReporter
        self.logger = logger
        self.personalDataURLDecoder = personalDataURLDecoder
        self.didFinish = didFinish
        self.visitedWebsite = visitedWebsite
        self.domainLibrary = domainLibrary
        self.userSettings = userSettings
        self.item = Credential()
        self.item.editableURL = visitedWebsite ?? ""
        emailsSubcription = database
            .itemsPublisher(for: CorePersonalData.Email.self)
            .map { Array($0) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.emails, on: self)
    }
    
    func makePasswordGeneratorViewModel() -> PasswordGeneratorViewModel {
        return PasswordGeneratorViewModel(
            mode: .selection(item, { [weak self] generated in
                self?.item.password = generated.password ?? ""
            }),
            database: database,
            passwordEvaluator: passwordEvaluator,
            usageLogService: usageLogService,
            sessionActivityReporter: activityReporter,
            userSettings: userSettings)
    }
    
    func prepareForSaving() {
        if let url = try? personalDataURLDecoder.decodeURL(item.editableURL) {
            item.url = url
            if let domain = url.domain {
                item.title = domain.name.removingPercentEncoding ?? domain.name
            }
        }
    }

    func save() {
        activityReporter.report(UserEvent.UpdateVaultItem(action: .add,
                                                          itemId: item.userTrackingLogID,
                                                          itemType: .credential,
                                                          space: item.userTrackingSpace))

        activityReporter.report(UserEvent.AutofillAccept(dataTypeList: [.credential]))
        activityReporter.report(AnonymousEvent.AutofillAccept(domain: item.hashedDomainForLogs))
        do {
            let savedItem = try database.save(item)
            item = savedItem
        } catch {
            logger.sublogger(for: AppLoggerIdentifier.personalData).error("Error on save", error: error)
        }
    }
    
    func makeIconViewModel() -> VaultItemIconViewModel {
        VaultItemIconViewModel(item: item, iconLibrary: domainLibrary)
    }
}
