import Foundation
import CoreSession
import CoreIPC
import Combine
import SwiftTreats

extension AppCoordinator {
    func createSessionFromUITestCommandIfNeeded() {
        Task {

            guard ProcessInfo.isTesting else {
                return
            }
            let rawURL = ProcessInfo.processInfo.environment["SIMULATOR_SHARED_RESOURCES_DIRECTORY"]! + "/uitestmessager"
            let url = URL(fileURLWithPath: rawURL)
            print("URL used for UITests messaging: \(url.absoluteString)")

            let listener = IPCMessageListener<SessionConfiguration>(urlToObserve: url,
                                                                    coder: IPCUnsecureMessageCoder(),
                                                                    logger: self.appServices.rootLogger[.session])

            for await configuration in listener.messages {
                do {
                    try await self.login(using: configuration)
                } catch {
                    fatalError("Auto login failed \(error)")
                }
            }
        }
    }

    @MainActor
    func login(using configuration: SessionConfiguration) async throws {
        try appServices.sessionContainer.removeSessionDirectory(for: configuration.login)
        let session = try appServices.sessionContainer.createSession(with: configuration, cryptoConfig: .masterPasswordBasedDefault)
        let services = try await withCheckedThrowingContinuation { continuation in
            sessionServicesSubscription = SessionServicesContainer.buildSessionServices(from: session,
                                                                                        appServices: self.appServices,
                                                                                        logger: appServices.rootLogger[.session],
                                                                                        loadingContext: .remoteLogin) { result in
                continuation.resume(with: result)
            }
        }

        startConnectedCoordinator(using: services)
    }
}
