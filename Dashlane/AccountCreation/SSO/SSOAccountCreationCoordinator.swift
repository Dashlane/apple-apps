import Foundation
import CoreSession
import CorePersonalData
import DashlaneCrypto
import DashTypes
import CoreNetworking
import Combine
import AuthenticationServices
import CoreUserTracking
import Logger
import DashlaneAppKit
import SwiftTreats
import LoginKit
import CoreLocalization
import CoreSync
import CyrilKit
import UIComponents

@MainActor
class SSOAccountCreationCoordinator: NSObject, Coordinator {

    enum Step: Equatable {
        case authenticate(_ serviceProviderUrl: String)
        case userConsent(_ ssoToken: String, _ serviceProviderKey: String)
        case createAccount(_ ssoToken: String, _ serviceProviderKey: String, _ hasUserAcceptedTermsAndConditions: Bool, _ hasUserAcceptedEmailMarketing: Bool)
    }

    enum CompletionResult {
        case accountCreated(SessionServicesContainer)
        case cancel
    }

    let email: DashTypes.Email
    let navigator: Navigator
    private let completion: (CompletionResult) -> Void
    private let isEmailMarketingOptInRequired: Bool
    private let initialStep: Step
    private let appServices: AppServicesContainer
    private let creationLogger: Logger
    private let logger: Logger
    private var sessionServicesSubscription: AnyCancellable?
    private let isNitroProvider: Bool

    init(email: DashTypes.Email,
         appServices: AppServicesContainer,
         navigator: Navigator,
         isEmailMarketingOptInRequired: Bool,
         logger: Logger,
         initialStep: Step,
         isNitroProvider: Bool,
         completion: @escaping (CompletionResult) -> Void) {
        self.email = email
        self.navigator = navigator
        self.completion = completion
        self.isEmailMarketingOptInRequired = isEmailMarketingOptInRequired
        self.initialStep = initialStep
        self.appServices = appServices
        self.logger = logger
        self.creationLogger = appServices.rootLogger[.accountCreation]
        self.isNitroProvider = isNitroProvider
    }

    func start() {
        move(to: initialStep)
    }

    private func move(to step: Step) {
        switch step {
        case let .authenticate(serviceProviderUrl):
            authenticate(serviceProviderUrl: serviceProviderUrl)
        case let .userConsent(ssoToken, serviceProviderKey):
            navigator.push(makeUserConsentView(ssoToken: ssoToken, serviceProviderKey: serviceProviderKey))
        case let .createAccount(ssoToken, serviceProviderKey, hasUserAcceptedTermsAndConditions, hasUserAcceptedEmailMarketing):
            Task {
                await createAccount(ssoToken: ssoToken,
                              serviceProviderKey: serviceProviderKey,
                              hasUserAcceptedTermsAndConditions: hasUserAcceptedTermsAndConditions,
                              hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing)
            }

        }
    }

    func authenticate(serviceProviderUrl: String) {

        guard let url = URL(string: serviceProviderUrl) else {
            self.showError(AccountError.unknown)
            return
        }

        if isNitroProvider {
            ssoNitroLogin()
        } else {
            ssoLogin(with: url)
        }
    }

    func ssoLogin(with serviceProviderUrl: URL) {
        let model = SelfHostedSSOViewModel(login: email.address, authorisationURL: serviceProviderUrl) { result in
            self.handleSSOLoginResult(result)
        }
        navigator.push(SelfHostedSSOView(model: model, clearCookies: true), barStyle: .transparent, animated: true)
    }

    func ssoNitroLogin() {
        let model = NitroSSOLoginViewModel(login: email.address, nitroWebService: appServices.nitroWebService) { result in
            self.handleSSOLoginResult(result)
        }
        navigator.push(NitroSSOLoginView(model: model, clearCookies: true), barStyle: .transparent, animated: true)
    }

    func handleSSOLoginResult(_ result: Result<SSOCallbackInfos, Error>) {
        DispatchQueue.main.async {
            switch result {
            case let .success(callbackInfos):
                self.move(to: .userConsent(callbackInfos.ssoToken, callbackInfos.serviceProviderKey))
            case .failure:
                self.navigator.pop()
                self.showError(AccountError.unknown)
            }
        }
    }

    func makeUserConsentView(ssoToken: String, serviceProviderKey: String) -> SSOUserConsentView {
        let model = SSOUserConsentViewModel(isEmailMarketingOptInRequired: isEmailMarketingOptInRequired) { result in
            switch result {
            case let .finished(hasUserAcceptedTermsAndConditions, hasUserAcceptedEmailMarketing):
                self.move(to: Step.createAccount(ssoToken,
                                                 serviceProviderKey,
                                                 hasUserAcceptedTermsAndConditions,
                                                 hasUserAcceptedEmailMarketing))
            case .cancel:
                self.completion(.cancel)
            }
        }
        return SSOUserConsentView(model: model)
    }

    func createAccount(ssoToken: String,
                       serviceProviderKey: String,
                       hasUserAcceptedTermsAndConditions: Bool,
                       hasUserAcceptedEmailMarketing: Bool) async {
        do {
                        let ssoServerKey = Random.randomData(ofSize: 64)
            let remoteKey = Random.randomData(ofSize: 64)
            guard let serviceProviderKeyData = Data(base64Encoded: serviceProviderKey) else {
                creationLogger.error("Incorrect serviceProviderKey")
                self.showError(AccountError.unknown)
                return
            }
            let ssoKey = ssoServerKey ^ serviceProviderKeyData 

            guard  let sessionCryptoEngine = try? appServices.sessionCryptoEngineProvider.sessionCryptoEngine(for: .ssoKey(ssoKey)),
                   let remoteCryptoEngine = try? appServices.sessionCryptoEngineProvider.cryptoEngine(for: remoteKey),
                   let encryptedRemoteKey = sessionCryptoEngine.encrypt(data: remoteKey)
                   else {
                creationLogger.error("Failed to encrypt remote key")
                self.showError(AccountError.unknown)
                return
            }
            let cryptoConfig = sessionCryptoEngine.config

            let initialSettings = try Settings(cryptoConfig: cryptoConfig, email: email.address)
                .makeTransactionContent()
                .encrypt(using: remoteCryptoEngine)
                .base64EncodedString()

            let settings = CoreSessionSettings(content: initialSettings, time: Int(Timestamp.now.rawValue))
            let consents = [Consent(consentType: .emailsOffersAndTips, status: hasUserAcceptedEmailMarketing),
                            Consent(consentType: .privacyPolicyAndToS, status: true)]

            guard let sharingKeys = try? SharingKeys.makeAccountDefault(privateKeyCryptoEngine: remoteCryptoEngine) else {
                creationLogger.error("Failed to create sharing keys")
                self.showError(AccountError.unknown)
                return
            }

            let creationInfo = SSOAccountCreationInfos(email: String(email.address),
                                                   settings: settings,
                                                   consents: consents,
                                                   sharingKeys: sharingKeys,
                                                   ssoToken: ssoToken,
                                                   ssoServerKey: ssoServerKey.base64EncodedString(),
                                                   remoteKeys: [AppAPIClient.Account.CreateUserWithSSO.RemoteKeys(uuid: UUID().uuidString.lowercased(),
                                                                          key: encryptedRemoteKey.base64EncodedString(),
                                                                          type: .sso)])

            await self.createSSOAccount(with: creationInfo, ssoKey: ssoKey, remoteKey: remoteKey, cryptoConfig: cryptoConfig)
        } catch {
            creationLogger.error("Failed to create account", error: error)
            self.showError(AccountError.unknown)
        }
    }
}

@MainActor
extension SSOAccountCreationCoordinator {

    func createSSOAccount(with accountInfos: SSOAccountCreationInfos, ssoKey: Data, remoteKey: Data, cryptoConfig: CryptoRawConfig) async {
        do {
            let accountInfo = try await self.appServices.appAPIClient.account.createSSOAccount(with: accountInfos)
            let authentication = ServerAuthentication(deviceAccessKey: accountInfo.deviceAccessKey, deviceSecretKey: accountInfo.deviceSecretKey)
            let sessionConfiguration = SessionConfiguration(login: Login(accountInfos.login),
                                                            masterKey: .ssoKey(ssoKey),
                                                            keys: SessionSecureKeys(serverAuthentication: authentication,
                                                                                    remoteKey: remoteKey,
                                                                                    analyticsIds: AnalyticsIdentifiers(device: accountInfo.deviceAnalyticsId, user: accountInfo.userAnalyticsId)),
                                                            info: SessionInfo(deviceAccessKey: accountInfo.deviceAccessKey,
                                                                              loginOTPOption: nil,
                                                                              accountType: .sso))
            self.createSession(with: sessionConfiguration, cryptoConfig: cryptoConfig)
        } catch {
            self.showError(error)
            self.logger.error("Failed to create account", error: error)
        }
    }

    private func makeLoginHandler() -> LoginHandler {
        return LoginHandler(sessionsContainer: appServices.sessionContainer,
                            appApiClient: appServices.appAPIClient,
                            apiClient: appServices.appAPIClient,
                            deviceInfo: DeviceInfo.default,
                            logger: self.logger,
                            cryptoEngineProvider: appServices.sessionCryptoEngineProvider,
                            removeLocalDataHandler: appServices.sessionCleaner.removeLocalData)
    }

	private func createSession(with sessionConfiguration: SessionConfiguration, cryptoConfig: CryptoRawConfig) {
		Task.detached {
			do {
				let session = try await self.makeLoginHandler().createSession(with: sessionConfiguration, cryptoConfig: cryptoConfig)
				await self.buildSessionServices(from: session)
			} catch {
				self.logger.error("Failed to create session", error: error)
			}
		}
	}

	@MainActor
    func buildSessionServices(from session: Session) {
        self.sessionServicesSubscription = SessionServicesContainer
            .buildSessionServices(from: session,
                                  appServices: self.appServices,
                                  logger: self.logger,
                                  loadingContext: .accountCreation) { [weak self] result in
                                    guard let self = self else { return }

                                    switch result {
                                    case let .success(sessionServices):
                                        sessionServices.activityReporter.logSuccessfulLogin()
                                        self.completion(.accountCreated(sessionServices))
                                    case let .failure(error):
                                        self.showError(error)
                                        self.logger.error("Failed to create account", error: error)
                                        self.completion(.cancel)
                                    }
        }
    }

    private func showError(_ error: Error) {
        let alert: UIAlertController = {
            if case AccountCreationError.expiredVersion = error {
                return VersionValidityAlert.errorAlert()
            } else {
                let title = CoreLocalization.L10n.errorMessage(for: error)
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: CoreLocalization.L10n.Core.kwButtonOk, style: .default, handler: nil))
                return alert
            }
        }()

        DispatchQueue.main.async {
            self.navigator.topViewController?.present(alert, animated: true)
        }
    }
}

extension SSOAccountCreationInfos {
    init(email: String, settings: CoreSessionSettings, consents: [Consent], sharingKeys: SharingKeys, ssoToken: String, ssoServerKey: String, remoteKeys: [AppAPIClient.Account.CreateUserWithSSO.RemoteKeys]) {
            self.init(login: email,
                      contactEmail: email,
                      appVersion: Application.version(),
                      platform: AccountCreateUserPlatform(rawValue: System.platform) ?? .serverIphone,
                      settings: settings,
                      deviceName: Device.name,
                      country: System.country,
                      language: System.language,
                      sharingKeys: sharingKeys,
                      consents: consents,
                      ssoToken: ssoToken,
                      ssoServerKey: ssoServerKey,
                      remoteKeys: remoteKeys)
    }
}

private extension ActivityReporterProtocol {
    func logSuccessfulLogin() {
        report(UserEvent.Login(isFirstLogin: true,
                               mode: .sso,
                               status: .success,
                               verificationMode: Definition.VerificationMode.none))
    }
}
