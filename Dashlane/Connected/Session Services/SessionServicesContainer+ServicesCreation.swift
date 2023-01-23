import Foundation
import Combine
import CoreSession
import DashTypes
import CoreUserTracking
import SwiftTreats
import DashlaneAppKit

extension SessionServicesContainer {

    static func buildSessionServices(from session: Session,
                                     appServices: AppServicesContainer,
                                     logger: Logger,
                                     loadingContext: SessionLoadingContext,
                                     completion: @MainActor @escaping (Result<SessionServicesContainer, Error>) -> Void) -> AnyCancellable? {
        Task.detached(priority: .userInitiated) {
            do {
                try appServices.sessionContainer.saveCurrentLogin(session.login)
                let sessionServices = try await SessionServicesContainer(appServices: appServices, session: session, loadingContext: loadingContext)
                appServices.rootLogger[.session].info("Session Services loaded")
                sessionServices.postLoad(using: sessionServices)
                await completion(.success(sessionServices))
            } catch {
                logger.error("Create Session Services failed", error: error)
                await completion(.failure(error))
            }
        }
        return nil
    }

         private func postLoad(using sessionServices: SessionServicesContainer) {
        sessionServices.activityReporter.postLoadConfigure(using: sessionServices, loadingContext: sessionServices.loadingContext)
        configureBraze(using: sessionServices)
        sessionServices.authenticatedABTestingService.reportClientControlledTests()

        #if targetEnvironment(macCatalyst)
        sessionServices.appServices.safariExtensionService.currentSession = sessionServices.session
        #endif
    }

    private func configureBraze(using sessionServices: SessionServicesContainer) {
        Task.detached(priority: .low) {
            await sessionServices.appServices.brazeService.registerLogin(sessionServices.session.login,
                                                                         using: sessionServices.spiegelUserSettings,
                                                                         webservice: sessionServices.legacyWebService,
                                                                         featureService: sessionServices.featureService)
        }
    }
}
