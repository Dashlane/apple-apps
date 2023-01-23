import Foundation
import DashTypes
import CorePasswords
import DomainParser
import SafariServices
import CorePersonalData
import CoreFeature

final class PluginService: NSObject {

    private enum RequestHandler {
        case nonAuthenticated(MaverickNonAuthenticatedRequestHandler)
        case authenticated(MaverickAuthenticatedRequestHandler, SessionServicesContainer)
        
        var handler: MaverickRequestHandler {
            switch self {
            case let .nonAuthenticated(handler):
                return handler
            case let .authenticated(handler, _):
                return handler
            }
        }
        
        var sessionServices: SessionServicesContainer? {
            guard case let .authenticated(_, container) = self else {
                return nil
            }
            return container
        }
    }
    
    private let messageDispatcher: AutofillMessageDispatcher
    private let logger: Logger
    
    private let maverickNonAuthenticatedRequestHandler: MaverickNonAuthenticatedRequestHandler
    private var requestHandler: RequestHandler
    
    init(appServices: AutofillAppServicesContainer,
        messageDispatcher: AutofillMessageDispatcher) {
        self.messageDispatcher = messageDispatcher
        self.logger = appServices.logger
        self.maverickNonAuthenticatedRequestHandler = MaverickNonAuthenticatedRequestHandler(appServices: appServices,
                                                                                             logger: logger)
        self.requestHandler = .nonAuthenticated(maverickNonAuthenticatedRequestHandler)
        super.init()
        
        messageDispatcher.addObserver(on: .plugin, listener: self) { [weak self] communication in
            guard let self = self else {
                return
            }

            Task {
                await self.handleCommunication(communication)
            }
        }
    }
    
    public func connect(sessionServicesContainer: SessionServicesContainer) {
        let authenticatedHandler = MaverickAuthenticatedRequestHandler(nonAuthenticatedRequestHandler: maverickNonAuthenticatedRequestHandler,
                                                                       sessionServicesContainer: sessionServicesContainer,
                                                                       logger: logger)
        self.requestHandler = .authenticated(authenticatedHandler,
                                             sessionServicesContainer)
        postSessionState()
        postFeaturesUpdate()
    }
    
    public func disconnect() {
        requestHandler = .nonAuthenticated(maverickNonAuthenticatedRequestHandler)
        postSessionState()
    }
    
    deinit {
        messageDispatcher.removeObserver(for: .plugin, listener: self)
    }

    enum Order: String {
        case sessionStateRequest = "stateRequest"
        case maverickRequest = "mfaRequest"
    }
    
    private func handleCommunication(_ communication: Communication) async {
        guard let order = Order(rawValue: communication.subject) else {
            assertionFailure("Unhandled order \(communication.subject)")
            return
        }

        switch order {
        case .sessionStateRequest:
            guard let action = SessionStateRequest.action(from: communication) else {
                postSessionState()
                return
            }

            switch action {
            case .`init`:
                postSessionState()
                self.postFeaturesUpdate()
            case .askLoginPopup:
                NSWorkspace.shared.openMainApplication()
            case .openApplication:
                guard let openApplicationRequest = communication.fromBody(SessionStateRequest.Body<OpenApplicationRequest>.self)?.message.userInfo else {
                    assertionFailure()
                    return
                }
                openApplicationRequest.perform()
            }

        case .maverickRequest:
                        guard let order = communication.fromBody(MaverickOrder.self) else {
                logger.error("Error parsing maverick request \(communication.body)")
                return
            }
            do {
                                guard let communication = try await requestHandler.handler
                        .performOrder(order) else {
                    return
                }
                messageDispatcher.post(communication)
            } catch {
                logger.error("Error performing maverick request \(order.message)", error: error)
            }
        }
    }
    
    private func postSessionState() {
        guard let communication = SessionStateRequest(userLogin: requestHandler.sessionServices?.session.login.email,
                                                      featureService: nil).perform(order: .userStatus) else {
            return
        }
        messageDispatcher.post(communication)
    }

        func postFeaturesUpdate() {
        guard let communication = SessionStateRequest(userLogin: requestHandler.sessionServices?.session.login.email,
                                                      featureService: requestHandler.sessionServices?.featureService).perform(order: .capacities) else {
            return
        }
        messageDispatcher.post(communication)
    }
}
