import Foundation
import CorePersonalData
import AuthenticationServices
import CoreData
import DashTypes
import CoreSession
import CoreUserTracking
import SwiftUI
import SwiftTreats
import AutofillKit
import UIComponents
import LoginKit

class AutofillRootCoordinator: Coordinator, SubcoordinatorOwner {

    let context: ASCredentialProviderExtensionContext
    let appServices: AppServicesContainer
    let loginKitServices: LoginKitServicesContainer
    
    unowned var rootNavigationController: DashlaneNavigationController!
    var subcoordinator: Coordinator?
        var persistedSessionServices: SessionServicesContainer?

        var allAppMessages: [AppExtensionCommunicationCenter.Message] = []

    init(context: ASCredentialProviderExtensionContext,
         rootViewController: DashlaneNavigationController,
         sharedSessionServices: SessionServicesContainer?) {
        self.appServices = AppServicesContainer.sharedInstance
        appServices.appSettings.configure()
        self.context = context
        self.rootNavigationController = rootViewController
        self.persistedSessionServices = sharedSessionServices
        self.loginKitServices = appServices.makeLoginKitServicesContainer()
    }
    
    func start() {}

        func handleAppExtensionCommunication(completion: @escaping Completion<Void>) {
        let messagesReceived: Set<AppExtensionCommunicationCenter.Message> = appServices.appExtensionCommunication.consumeMessages()
        
        self.allAppMessages += messagesReceived

                guard persistedSessionServices != nil else {
            completion(.success)
            return
        }

                if messagesReceived.contains(.userDidLogout) ||
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
                                                                  navigator: rootNavigationController,
                                                                  localLoginFlowViewModelFactory: .init( loginKitServices.makeLocalLoginFlowViewModel)) {[weak self] result in
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

    fileprivate func cancelRequest() {
        context.cancelRequest(withError: ASExtensionError.userCanceled.nsError)
        self.persistedSessionServices = nil
    }

    private func autofillCompleted(selection: CredentialSelection?) {
        guard let selection = selection else {
            cancelRequest()
            return
        }
        context.completeRequest(withSelectedCredential: ASPasswordCredential(credential: selection.credential)) { _ in }
        self.persistedSessionServices = nil
    }
    
    @MainActor
    private func displayErrorStateOrCancelRequest(error: Error) async {
        if case let  AuthenticationCoordinator.AuthError.noUserConnected(details) = error {
            let view = AutofillErrorView(with: self, error: .noUserConnected(details: details))
            rootNavigationController.viewControllers = [UIHostingController(rootView: view)]
        } else if case AuthenticationCoordinator.AuthError.ssoUserWithNoAccountCreated = error {
            let view = AutofillErrorView(with: self, error: .ssoUserWithNoConvenientLoginMethod)
            rootNavigationController.viewControllers = [UIHostingController(rootView: view)]
        }
        else {
            cancelRequest()
        }
    }
}

extension AutofillRootCoordinator: AutofillURLOpener {
    func openUrl(_ url: URL) {
        self.openURL(url)
    }

    @discardableResult
    @objc private func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = rootNavigationController
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
}

extension AutofillRootCoordinator: CredentialProvider {
    func prepareInterfaceForExtensionConfiguration() {
        let configurationViewController: UIViewController
        #if !targetEnvironment(macCatalyst)
        configurationViewController = UIHostingController(rootView: CredentialProviderConfigurationView(completion: { [weak context] in
            context?.completeExtensionConfigurationRequest()
        }))
        rootNavigationController.present(configurationViewController, animated: false, completion: nil)
        #else
        configurationViewController = UIHostingController(rootView: CredentialProviderConfigurationCatalystView(completion: { [weak context] in
            context?.completeExtensionConfigurationRequest()
        }))
        rootNavigationController.setViewControllers([configurationViewController], animated: true)
        #endif


    }
    
    func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
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
            guard let sesssionServices = self.persistedSessionServices else {
                self.context.cancelRequest(withError: ASExtensionError.userInteractionRequired.nsError)
                return
            }
            let connectedCoordinator = self.makeConnectedCoordinator(with: sesssionServices, locked: false)
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

fileprivate extension AutofillErrorView {
    @MainActor init(with coordinator: AutofillRootCoordinator,
                    error: AutofillError) {
        self.init(error: error,
                  cancelAction: { [coordinator] in
            coordinator.cancelRequest()
        },
                  urlOpener: coordinator)
    }
}
