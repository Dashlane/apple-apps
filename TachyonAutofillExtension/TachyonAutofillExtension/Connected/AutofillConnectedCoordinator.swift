import Foundation
import DashTypes
import CorePersonalData
import CoreData
import AuthenticationServices
import DomainParser
import CoreKeychain
import TOTPGenerator
import Combine
import CoreUserTracking
import DashlaneAppKit
import Logger
import LoginKit

class AutofillConnectedCoordinator: Coordinator, SubcoordinatorOwner {

    let appServices: AppServicesContainer
    let context: ASCredentialProviderExtensionContext
    let sessionServices: SessionServicesContainer
    unowned var rootNavigationController: DashlaneNavigationController
    var subcoordinator: Coordinator?
    var serviceIdentifiers: [ASCredentialServiceIdentifier] = []
    var shouldShowLock: Bool
    var didSelectCredential: CredentialListViewModel.Completion
    var database: ApplicationDatabase {
        return sessionServices.database
    }
    var tachyonInstallLogger: TachyonLogger? {
        return appServices.installerLogService.tachyonLogger
    }
    private let localNotificationService: LocalNotificationService

    init(sessionServicesContainer: SessionServicesContainer,
         appServicesContainer: AppServicesContainer,
         context: ASCredentialProviderExtensionContext,
         rootNavigationController: DashlaneNavigationController,
         locked: Bool,
         didSelectCredential: @escaping CredentialListViewModel.Completion) {
        self.appServices = appServicesContainer
        self.context = context
        self.sessionServices = sessionServicesContainer
        self.rootNavigationController = rootNavigationController
        self.shouldShowLock = locked
        self.didSelectCredential = didSelectCredential
        self.localNotificationService = LocalNotificationService(usageLogService: self.sessionServices.usageLogService)
    }

    @MainActor
    func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier], context: ASCredentialProviderExtensionContext) {
        configureAppearance()
        if shouldShowLock {
            self.serviceIdentifiers = serviceIdentifiers
            Task {
               await startAuthentication()
            }
        } else {
            startListCoordinator(for: serviceIdentifiers, context: context)
        }
    }

    @MainActor
    @discardableResult
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = rootNavigationController.topViewController
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
    
    private func configureAppearance() {
        UITableView.appearance().backgroundColor = FiberAsset.tableBackground.color
        UITableViewCell.appearance().backgroundColor = FiberAsset.cellBackground.color
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().sectionHeaderTopPadding = 0.0
    }

    @MainActor
    private func startListCoordinator(for serviceIdentifiers: [ASCredentialServiceIdentifier], context: ASCredentialProviderExtensionContext) {
        let model = CredentialListViewModel(syncService: sessionServices.syncService,
                                            database: sessionServices.database,
                                            autofillService: sessionServices.autofillService,
                                            domainIconLibrary: sessionServices.domainIconLibrary,
                                            tachyonLogger: sessionServices.appServices.installerLogService.tachyonLogger,
                                            logger: sessionServices.appServices.rootLogger,
                                            usageLogService: sessionServices.usageLogService,
                                            sessionActivityReporter: sessionServices.activityReporter,
                                            personalDataURLDecoder: sessionServices.appServices.personalDataURLDecoder,
                                            passwordEvaluator: sessionServices.appServices.passwordEvaluator,
                                            userSettings: sessionServices.userSettings,
                                            serviceIdentifiers: serviceIdentifiers,
                                            teamSpacesService: sessionServices.teamSpacesService,
                                            domainParser: sessionServices.appServices.domainParser,
                                            premiumStatus: sessionServices.premiumStatus,
                                            associatedDomainsService: sessionServices.appServices.linkedDomainService,
                                            featureService: sessionServices.featureService,
                                            openUrl: openURL(_:),
                                            completion: { [weak self] in
            self?.didSelect($0)
        })
        let view = CredentialListView(model: model)
        self.rootNavigationController.setRootNavigation(view, barStyle: .hidden(), animated: true)
    }

    func didSelect(_ credentialSelection: CredentialSelection?) {
        if let selection = credentialSelection, let visitedWebsite = selection.visitedWebsite {
            sendOTPNotification(for: selection.credential)
            logSuccessAutofill(with: selection.credential,
                               visitedWebsite: visitedWebsite,
                               withoutUserInteraction: false,
                               matchType: selection.credential.matchType(for: visitedWebsite, linkedDomainService: sessionServices.appServices.linkedDomainService))
        }

        self.didSelectCredential(credentialSelection)
    }

    func logSuccessAutofill(with credential: Credential,
                            visitedWebsite: String,
                            withoutUserInteraction: Bool,
                            matchType: Definition.MatchType) {
        let credentialHost = URL(string: credential.editableURL)?.host
        let credentialDomain = credentialHost.flatMap(appServices.domainParser.parse)?.domain
        sessionServices.usageLogService.reportSuccessAutofill(for: credentialDomain,
                                                              visitedWebsite: visitedWebsite,
                                                              withoutUserInteraction: withoutUserInteraction)
        
        let event = UserEvent.PerformAutofill(autofillMechanism: .iosTachyon,
                                              autofillOrigin: .automatic,
                                              formTypeList: [.login],
                                              isAutologin: false,
                                              isManual: !withoutUserInteraction,
                                              matchType: matchType)
        sessionServices.activityReporter.report(event)
                
        let anonymousEvent = AnonymousEvent.PerformAutofill(autofillMechanism: .iosTachyon,
                                                            autofillOrigin: .automatic,
                                                            domain: credential.hashedDomainForLogs,
                                                            formTypeList: [.login],
                                                            isAutologin: false,
                                                            isManual: true,
                                                            isNativeApp: true,
                                                            matchType: matchType)
        appServices.activityReporter.report(anonymousEvent)
        
        do {
            let _ = try database.updateLastUseDate(for: [credential.id], origin: [.default])
        } catch {
            let logger = sessionServices.appServices.rootLogger
            logger.sublogger(for: AppLoggerIdentifier.personalData).error("Error on save", error: error)
        }
    }
    
    func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity,
                                                 completion: @escaping (Credential?) -> Void) {
        guard let id = credentialIdentity.recordIdentifier,
              let credential = try? database.fetch(with: Identifier(id), type: Credential.self) else {
            completion(nil)
            return
        }
        let visitedWebsite = credentialIdentity.serviceIdentifier.identifier
        
        sendOTPNotification(for: credential)

        logSuccessAutofill(with: credential,
                           visitedWebsite: visitedWebsite,
                           withoutUserInteraction: true,
                           matchType: credential.matchType(for: visitedWebsite, linkedDomainService: sessionServices.appServices.linkedDomainService))

        completion(credential)
    }

    func start() {}
    
    func logLogin() {
        if let performanceLogInfo = sessionServices.usageLogService.getPerformanceLogInfo() {
            sessionServices.activityReporter.report(performanceLogInfo.performanceUserEvent(for: .timeToLoadAutofill))
        }
        sessionServices.usageLogService.logLogin()
    }
}

private extension Credential {
    func matchType(for website: String, linkedDomainService: LinkedDomainProvider) -> Definition.MatchType {
        if manualAssociatedDomains.contains(website) {
            return .remembered
        }

        if let domain = url?.domain?.name , let associatedDomains = linkedDomainService[domain] {
            for associatedDomain in associatedDomains where website.contains(associatedDomain) {
                return .associatedWebsite
            }
        }

        for linkedService in linkedServices.associatedDomains {
            if website.contains(linkedService.domain) {
                switch linkedService.source {
                case.remember: return .remembered
                case .manual: return .userAssociatedWebsite
                }
            }
        }

        return .regular
    }
}

private extension AutofillConnectedCoordinator {
    func sendOTPNotification(for credential: Credential) {
        if let otpURL = credential.otpURL, let otpInfo = try? OTPConfiguration(otpURL: otpURL) {
            
            let code = TOTPGenerator.generate(with: otpInfo.type, for: Date(), digits: otpInfo.digits, algorithm: otpInfo.algorithm, secret: otpInfo.secret)
            let hasClipboardOverride: Bool? = sessionServices.userSettings[.clipboardOverrideEnabled]

            if hasClipboardOverride == true {
                PasteboardService(userSettings: sessionServices.userSettings).set(code)
            }

            let otpNotification = OTPLocalNotification(pin: code, itemId: credential.id.rawValue,
                                                       hasClipboardOverride: hasClipboardOverride ?? false,
                                                       domain: credential.url?.displayDomain)
            localNotificationService.send(otpNotification)
        }
    }
}

extension AutofillConnectedCoordinator {
    @MainActor
    private func startAuthentication() async {
        let coordinator = AuthenticationCoordinator(appServices: appServices,
                                                    navigator: rootNavigationController,
                                                    inputMode: .servicesLoaded(sessionServices)) { result in
            switch result {
            case .success:
                self.startListCoordinator(for: self.serviceIdentifiers, context: self.context)
            case .failure(let error):
                self.context.cancelRequest(withError: error)
            }
        }
        startSubcoordinator(coordinator)
    }
}
