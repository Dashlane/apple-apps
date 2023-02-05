import Foundation
import CorePersonalData
import AuthenticationServices
import CoreData
import DashTypes
import CoreSession
import CoreUserTracking
import SwiftUI
import SwiftTreats

class AutofillRootCoordinator: Coordinator, SubcoordinatorOwner {

    let context: ASCredentialProviderExtensionContext
    let appServices: AppServicesContainer
    unowned var rootNavigationController: DashlaneNavigationController!
    var subcoordinator: Coordinator?
        var persistedSessionServices: SessionServicesContainer?
    var logger: TachyonLogger? { return appServices.installerLogService.tachyonLogger }
    
        var allAppMessages: [AppExtensionCommunicationCenter.Message] = []

    init(context: ASCredentialProviderExtensionContext,
         rootViewController: DashlaneNavigationController,
         sharedSessionServices: SessionServicesContainer?) {
        self.appServices = AppServicesContainer.sharedInstance
        appServices.appSettings.configure()
        self.context = context
        self.rootNavigationController = rootViewController
        self.persistedSessionServices = sharedSessionServices
    }
    
    func start() {}

        func handleAppExtensionCommunication(completion: @escaping Completion<Void>) {
        let messagesReceived = appServices.appExtensionCommunication.consumeMessages()
        
        self.allAppMessages += messagesReceived

                guard persistedSessionServices != nil else {
            completion(.success)
            return
        }

                        if messagesReceived.contains(.userDidLogout) ||
            messagesReceived.contains(.dataMutated) ||
            messagesReceived.contains(.premiumStatusDidUpdate) {
            self.persistedSessionServices = nil
            SessionServicesContainer.shared = nil
            completion(.success)
        } else {
            completion(.success)
        }
    }
    
            func retrieveConnectedCoordinator(fromQuickbar: Bool = false,
                                      completion: @escaping (Result<AutofillConnectedCoordinator, Error>) -> Void) {
        handleAppExtensionCommunication { [weak self] _ in
            guard let self = self else { return }
            if let sessionServices = self.persistedSessionServices {
                                                if fromQuickbar && self.allAppMessages.contains(.dataMutated) {
                    self.persistedSessionServices = nil
                    SessionServicesContainer.shared = nil
                    Task { @MainActor in
                        await self.startAuthentication(completion: completion)
                    }
                }
                                                sessionServices.syncService.sync(triggeredBy: .periodic)
                completion(.success(self.makeConnectedCoordinator(with: sessionServices, locked: true)))
            } else {
                Task { @MainActor in
                    await self.startAuthentication(completion: completion)
                }
            }
        }
     }

    @MainActor
    func startAuthentication(completion: @escaping (Result<AutofillConnectedCoordinator, Error>) -> Void) async {
        let authenticationCoordinator = AuthenticationCoordinator(appServices: appServices,
                                                                  navigator: rootNavigationController) {[weak self] result in
                                                                    guard let self = self else { return }
                                                                    self.postAuthentication(sessionServicesResult: result,
                                                                                            completion: completion)
            
        }
        startSubcoordinator(authenticationCoordinator)
    }
    
    func postAuthentication(sessionServicesResult: Result<SessionServicesContainer, Error>, completion: @escaping (Result<AutofillConnectedCoordinator, Error>) -> Void) {
        switch sessionServicesResult {
            case let .success(sessionServices):
                                                guard sessionServices.syncService.hasAlreadySync() else {
                    Task {
                        await self.displayErrorStateOrCancelRequest(error: AuthenticationCoordinator.AuthError.noUserConnected(details: "emptydb"))
                    }
                    return
                }
                
                completion(.success(self.makeConnectedCoordinator(with: sessionServices, locked: false)))
            case let .failure(error):
                completion(.failure(error))
        }
    }
    
    func makeConnectedCoordinator(with sessionServices: SessionServicesContainer, locked: Bool) -> AutofillConnectedCoordinator {
        let connectedCoordinator = AutofillConnectedCoordinator(sessionServicesContainer: sessionServices,
                                            appServicesContainer: appServices,
                                            context: context,
                                            rootNavigationController: rootNavigationController,
                                            locked: locked,
                                            didSelectCredential: { [weak self] in self?.autofillCompleted(selection: $0) })
        self.subcoordinator = connectedCoordinator
        return connectedCoordinator
    }

    private func cancelRequest() {
        logger?.log(LifeCycleLogEvent.failed(userInteractionRequired: false))
        context.cancelRequest(withError: ASExtensionError.userCanceled.nsError)
        self.persistedSessionServices = nil
    }

    private func autofillCompleted(selection: CredentialSelection?) {
        guard let selection = selection else {
            cancelRequest()
            return
        }
        logger?.log(LifeCycleLogEvent.completed(selection))
        context.completeRequest(withSelectedCredential: ASPasswordCredential(credential: selection.credential)) { _ in }
        self.persistedSessionServices = nil
    }
    
    @MainActor
    private func displayErrorStateOrCancelRequest(error: Error) async {
        if case let  AuthenticationCoordinator.AuthError.noUserConnected(details) = error {
            let errorStateCoordinator = ErrorStateCoordinator(rootNavigationController: self.rootNavigationController, error: .noUserConnected(details: details), tachyonLogger: appServices.installerLogService.tachyonLogger, completion: { [weak self] closed in
                self?.cancelRequest()
            })
            startSubcoordinator(errorStateCoordinator)
        } else if case AuthenticationCoordinator.AuthError.ssoUserWithNoAccountCreated = error {
                let errorStateCoordinator = ErrorStateCoordinator(rootNavigationController: self.rootNavigationController, error: .ssoUserWithNoConvenientLoginMethod, tachyonLogger: appServices.installerLogService.tachyonLogger, completion: { [weak self] closed in
                    self?.cancelRequest()
                })
            startSubcoordinator(errorStateCoordinator)
            }
            else {
                cancelRequest()
            }
    }
}

extension AutofillRootCoordinator: CredentialProvider {
    func prepareInterfaceForExtensionConfiguration() {
        let configurationViewController: UIViewController
        #if !targetEnvironment(macCatalyst)
        configurationViewController = StoryboardScene.TachyonInterface.configurationScreen.instantiate(input: CredentialProviderConfigurationViewController.Input(completion: { [weak context] in
            context?.completeExtensionConfigurationRequest()
        }))
        rootNavigationController.present(configurationViewController, animated: false, completion: nil)
        #else
        configurationViewController = UIHostingController(rootView: CredentialProviderConfigurationCatalystView(completion: { [weak context] in
            context?.completeExtensionConfigurationRequest()
        }))
        rootNavigationController.setViewControllers([configurationViewController], animated: true)
        #endif
        logger?.log(ConfigurationScreenLogEvent.displayed)


    }
    
    func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        logger?.log(LifeCycleLogEvent.started(domain: serviceIdentifiers.first?.identifier,
                                                     preselectedCredential: false,
                                                     alreadyAuthenticated: persistedSessionServices != nil))

        retrieveConnectedCoordinator { [weak self, context] result in
            do {
                let sessionCoordinator = try result.get()
                sessionCoordinator.logLogin()
                Task { @MainActor in
                    sessionCoordinator.prepareCredentialList(for: serviceIdentifiers, context: context)
                }
            } catch {
                Task {
                    await self?.displayErrorStateOrCancelRequest(error: error)
                }
            }
        }
    }

        func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        logger?.log(LifeCycleLogEvent.started(domain: credentialIdentity.serviceIdentifier.identifier,
                                                     preselectedCredential: true,
                                                     alreadyAuthenticated: persistedSessionServices != nil))

        retrieveConnectedCoordinator(fromQuickbar: true) { [weak self, context] result in
            guard let self = self else { return }
            switch result {
            case let .success(sessionCoordinator):
                sessionCoordinator.provideCredentialWithoutUserInteraction(for: credentialIdentity) { credential in
                    guard let credential = credential else {
                                                Task { @MainActor in
                            sessionCoordinator.prepareCredentialList(for: [], context: context)
                        }
                        return
                    }
                    self.autofillCompleted(selection: CredentialSelection(credential: credential,
                                                                          selectionOrigin: .quickTypeBar,
                                                                          visitedWebsite: credentialIdentity.serviceIdentifier.identifier))
                }
            case let .failure(error):
                Task {
                    await self.displayErrorStateOrCancelRequest(error: error)
                }
            }
        }
    }

        func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        handleAppExtensionCommunication {[weak self] _ in
            guard let self = self else { return }
            self.logger?.log(LifeCycleLogEvent.started(domain: credentialIdentity.serviceIdentifier.identifier,
                                                              preselectedCredential: true,
                                                              alreadyAuthenticated: self.persistedSessionServices != nil))
            guard let sessionServices = self.persistedSessionServices else {
                self.logger?.log(LifeCycleLogEvent.failed(userInteractionRequired: true))
                if self.allAppMessages.contains(.dataMutated) {
                    self.appServices.appExtensionCommunication.write(message: .dataMutated)
                }
                self.context.cancelRequest(withError: ASExtensionError.userInteractionRequired.nsError)
                return
            }
            let connectedCoordinator = self.makeConnectedCoordinator(with: sessionServices, locked: false)
            connectedCoordinator.provideCredentialWithoutUserInteraction(for: credentialIdentity) { credential in
                guard let credential = credential else {
                                                            self.context.cancelRequest(withError: ASExtensionError.userInteractionRequired.nsError)
                    return
                }
                self.autofillCompleted(selection: CredentialSelection(credential: credential,
                                                                      selectionOrigin: .quickTypeBar,
                                                                      visitedWebsite: credentialIdentity.serviceIdentifier.identifier))
            }
        }
    }
}

