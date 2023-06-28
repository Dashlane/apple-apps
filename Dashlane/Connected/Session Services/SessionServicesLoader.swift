import Foundation
import Combine
import CoreSession
import DashTypes
import CoreUserTracking
import SwiftTreats
import DashlaneAppKit

struct SessionServicesLoader {
    let appServices: AppServicesContainer
    let logger: Logger

    func load(for session: Session, context: SessionLoadingContext) async throws -> SessionServicesContainer {
        do {
            let sessionServices = try await SessionServicesContainer(appServices: appServices, session: session, loadingContext: context)
            try appServices.sessionContainer.saveCurrentLogin(session.login)
            await sessionServices.postLoad()
            return sessionServices
        } catch {
            logger.error("Create Session Services failed", error: error)
            throw error
        }
    }
}

extension AppServicesContainer {
    var sessionServicesLoader: SessionServicesLoader {
        SessionServicesLoader(appServices: self, logger: rootLogger[.session])
    }
}

extension SessionServicesContainer {

        static func buildSessionServices(from session: Session,
                                     appServices: AppServicesContainer,
                                     logger: Logger,
                                     loadingContext: SessionLoadingContext,
                                     completion: @MainActor @escaping (Result<SessionServicesContainer, Error>) -> Void) -> AnyCancellable? {
        Task.detached(priority: .userInitiated) {
            do {
                let sessionServices = try await appServices.sessionServicesLoader.load(for: session, context: loadingContext)
                await completion(.success(sessionServices))
            } catch {
                logger.error("Create Session Services failed", error: error)
                await completion(.failure(error))
            }
        }
        return nil
    }
}
