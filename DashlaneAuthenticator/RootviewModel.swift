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
import DashlaneAppKit
import TOTPGenerator
import IconLibrary
import CoreUserTracking
import SwiftTreats
import UIKit

@MainActor 
class RootviewModel: ObservableObject {
    
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
    var currentRequest: AuthenticationRequest? = nil
    
    @SharedUserDefault(key: AuthenticatorKey.isAuthenticatorFirstLaunch, userDefaults: ApplicationGroup.authenticatorUserDefaults)
    public var isAuthenticatorFirstLaunch: Bool?
    
    let showWelcomeMessage = PassthroughSubject<Void, Never>()
    static let mode = CurrentValueSubject<AuthenticationMode?, Never>(nil)
    
    enum AppState: Equatable {
        case loading
        case paired(PairedViewModel)
        case standalone(StandaloneViewModel)
        case askForAuthentication(UnlockViewModel)
        static func ==(lhs: AppState, rhs: AppState) -> Bool {
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
                case let .paired(container):
                    return AppState.paired(PairedViewModel(services: container))
                case let .standAlone(container, passwordAppState):
                    return AppState.standalone(StandaloneViewModel(services: container,
                                                                   state: passwordAppState,
                                                                   unlock: { self.unlock(for: passwordAppState) }))
                case let .askForAuthentication(model):
                    return .askForAuthentication(model)
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
                } else if case let .paired(container) = appState {
                    self.fetchPendingRequests(with: container.services.authenticatorService)
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
        
        let model = UnlockViewModel(login: info.login, authenticationMode: info.authenticationMode, loginOTPOption: info.loginOTPOption, keychainService: appservices.keychainService, sessionContainer: appservices.sessionsContainer, appServices: appservices, validateMasterKey: self.validateMasterKey) { [self] sessionServices in
            self.appservices.applicationState.move(to: .paired(sessionServices))
            sessionServices.pairedDatabaseService.copyDBToVault()
        }
        appservices.applicationState.currentState = .askForAuthentication(model)
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
        var serverKey: String?
        if loginOTPOption != .none {
            serverKey = appservices.keychainService.serverKey(for: login)
        }
        
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
    
}
