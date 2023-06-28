import Foundation
import Combine
import CoreSession
import CoreSettings
import DashlaneAppKit
import CoreKeychain
import DashlaneCrypto
import SwiftTreats
import DashTypes
import CorePersonalData
import TOTPGenerator
import IconLibrary
import CoreUserTracking
import UIKit

@MainActor
class RootviewModel: ObservableObject {
        enum AppState: Equatable {
        case loading
        case paired(PairedServicesContainer)
        case standalone(StandAloneServicesContainer, PasswordAppState)
        case askForAuthentication(SessionLoadingInfo)
        static func == (lhs: AppState, rhs: AppState) -> Bool {
            switch(lhs, rhs) {
            case (.paired, .paired):
                return true
            case (.standalone, .standalone):
                return true
            case (.askForAuthentication, .askForAuthentication):
                return true
            default:
                return false
            }
        }
    }

        let appservices: AppServices

    @Published
    var appState: AppState

    @Published
    var pendingRequest: Set<AuthenticationRequest> = [] {
        didSet {
            showAnnouncement = !pendingRequest.isEmpty
        }
    }

    @Published
    var showAnnouncement: Bool = false

    @Published
    var currentRequest: AuthenticationRequest?

    @SharedUserDefault(key: AuthenticatorKey.isAuthenticatorFirstLaunch, userDefaults: ApplicationGroup.authenticatorUserDefaults)
    public var isAuthenticatorFirstLaunch: Bool?

    let showWelcomeMessage = PassthroughSubject<Void, Never>()
    static let mode = CurrentValueSubject<AuthenticationMode?, Never>(nil)

    @Published
    var presentError: Error?

    var subscriptions = Set<AnyCancellable>()

    var credentialsPublisher: AnyPublisher<[Credential], Never>?

    var sessionServices: PairedServicesContainer?

        init(appservices: AppServices) {
        self.appservices = appservices
        self.appState = .loading
        appservices.notificationService.registerForRemoteNotifications()
        subscribeToAuthenticationRequestNotifications()
        updateAppstate()
        reportAppLaunch()
    }

        func updateAppstate() {
        appservices.applicationState.$currentState
            .map({ (state) -> AppState in
                switch state {
                case .loading:
                    return .loading
                case let .paired(services):
                    return AppState.paired(services)
                case let .standAlone(services, passwordAppState):
                    return AppState.standalone(services, passwordAppState)
                case let .askForAuthentication(info):
                    return .askForAuthentication(info)
                }
            })
            .sink(receiveValue: { [weak self] appState in
                guard let self = self else { return }
                self.appState = appState
                if case .loading = appState {
                                        DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.checkForDashlanePasswordApp()
                    }
                } else if case let .paired(services) = appState {
                    self.fetchPendingRequests(with: services.authenticatorService)
                }
            })
            .store(in: &subscriptions)
    }

    func fetchPendingRequests(with webservice: SessionAuthenticatorService) {
        Task {
            if let pendingRequest = try? await webservice.pendingRequests() {
                self.pendingRequest = pendingRequest
                self.currentRequest = pendingRequest.first
            }
        }
    }

    func checkForDashlanePasswordApp() {
        let state = appservices.applicationState.passwordAppState()
        unlock(for: state)
    }

    func unlock(for state: PasswordAppState) {
        guard case let .locked(info) = state else {
            appservices.applicationState.move(to: .standAlone(StandAloneServicesContainer(appServices: appservices), state))
            return
        }
        appservices.applicationState.currentState = .askForAuthentication(info)
        Self.mode.send(info.authenticationMode)
    }

    private func subscribeToAuthenticationRequestNotifications() {
        appservices.notificationService.remoteNotificationPublisher.map { value in
            guard let value = value else {
                return nil
            }
            switch value {
            case .welcome:
                self.showWelcomeMessage.send()
                return nil
            case .requestAuthentication(let request):
                return request
            }
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$currentRequest)
    }

    func makeAuthenticationPushViewModel(for request: AuthenticationRequest,
                                         completion: @escaping (AuthenticationPushViewModel.Action?) -> Void) -> AuthenticationPushViewModel {
        return AuthenticationPushViewModel(notificationService: appservices.notificationService,
                                           request: request, completion: completion)
    }

    func validateMasterKey(_ masterKey: CoreKeychain.MasterKey, for login: Login, mode: AuthenticationMode, loginOTPOption: ThirdPartyOTPOption?) async throws -> PairedServicesContainer {
        let serverKey = appservices.keychainService.serverKey(for: login)
        let session = try appservices.sessionsContainer.loadSession(for: LoadSessionInformation(login: login, masterKey: masterKey.coreSessionMasterKey(withServerKey: serverKey)))

        return try await Task.detached(priority: .utility) {
            return try await PairedServicesContainer(session: session,
                                                     authenticationMode: mode,
                                                     appServices: self.appservices)
        }.value
    }

    func reportAppLaunch() {
        let isFirstLaunch = isAuthenticatorFirstLaunch == nil ? true : isAuthenticatorFirstLaunch!
        let hasPasswordManager = UIApplication.shared.canOpenURL(URL(string: "dashlane:///")!)
        if isFirstLaunch {
            isAuthenticatorFirstLaunch = false
            appservices.activityReporter.report(AnonymousEvent.OtherAuthenticatorsInstalledReport(otherAuthenticatorList: AnonymousEvent.OtherAuthenticatorsInstalledReport.other2FAappsInstalled))
        }
        appservices.activityReporter.report(UserEvent.AuthenticatorLaunch(hasPasswordManagerInstalled: hasPasswordManager, isFirstLaunch: isFirstLaunch))
    }

    func makePairedViewModel(services: PairedServicesContainer) -> PairedViewModel {
        .init(services: services)
    }

    func makeStandaloneViewModel(
        services: StandAloneServicesContainer,
        passwordAppState: PasswordAppState
    ) -> StandaloneViewModel {
        .init(
            services: services,
            state: passwordAppState,
            unlock: {
                self.unlock(for: passwordAppState)
            }
        )
    }

    func makeUnlockViewModel(
        info: SessionLoadingInfo
    ) -> UnlockViewModel {
        .init(
            login: info.login,
            authenticationMode: info.authenticationMode,
            loginOTPOption: info.loginOTPOption,
            keychainService: appservices.keychainService,
            sessionContainer: appservices.sessionsContainer,
            validateMasterKey: self.validateMasterKey
        ) { [self] sessionServices in
            self.appservices.applicationState.move(to: .paired(sessionServices))
            sessionServices.pairedDatabaseService.copyDBToVault()
        }
    }
}
