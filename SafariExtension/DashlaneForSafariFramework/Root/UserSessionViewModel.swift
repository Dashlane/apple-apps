import Foundation
import Combine
import CoreSession


class UserSessionViewModel: ObservableObject, UserSessionViewModelProtocol {
    
    private let appServices: SafariExtensionAppServices
    
    @Published
    var sessionState: SessionState
    
    private var cancellables = Set<AnyCancellable>()
    private var latestError: String?

    init(appServices: SafariExtensionAppServices) {
        self.appServices = appServices
        sessionState = .login(LoginViewModel(sessionSharing: appServices.sessionSharing, appSettings: appServices.globalSettings, loginError: latestError))        
        appServices.sessionSharing.$currentSession
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shareableSession in
                guard let self = self else { return }
                switch shareableSession {
                case .none:
                                        self.sessionState = .login(LoginViewModel(sessionSharing: appServices.sessionSharing, appSettings: appServices.globalSettings, loginError: self.latestError))
                    self.appServices.logout()
                case let .some(session):
                                        Task {
                        await self.load(session)
                    }
                }
                
            }.store(in: &cancellables)
    }
    
    func start() {
        self.appServices.sessionSharing.askForSession(silently: true)
    }
    
    func resume() {
        if self.appServices.sessionSharing.currentSession == nil {
            self.appServices.sessionSharing.askForSession(silently: true)
        }
    }
    
    @MainActor
    private func load(_ session: ShareableUserSession) async {
        self.sessionState = .loading
        let loader = SessionLoader(shareableSession: session,
                                   container: appServices.sessionsContainer)
        do {
            let session = try loader.session()
            
            let container = try await Task.detached(priority: .utility) {
                return try await SessionServicesContainer(appServices: self.appServices, session: session)
            }.value
            
            appServices.rootLogger[.session].info("Session Services loaded")
            
            let viewModel = ConnectedViewModel(session: session,
                                               appServices: self.appServices,
                                               sessionServicesContainer: container)
            sessionState = .connected(viewModel)
            latestError = nil
        } catch {
            latestError = "\(error)"
            appServices.sessionSharing.resetSession()
        }
    }

}
