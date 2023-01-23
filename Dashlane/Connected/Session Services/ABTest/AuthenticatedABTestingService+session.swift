import Foundation
import CoreFeature
import DashTypes
import Combine
import CoreSession
import DashlaneAppKit
import CoreSettings

extension AuthenticatedABTestingService {

                    convenience init(userSettings: UserSettings,
                     logger: Logger,
                     login: Login,
                     loadingContext: SessionLoadingContext,
                     authenticatedAPIClient: DeprecatedCustomAPIClient,
                     usageLogService: UsageLogService) async {
        self.init(logger: logger,
                  userEmail: login.email,
                  authenticatedAPIClient: authenticatedAPIClient,
                  isFirstLogin: loadingContext.isFirstLogin,
                  abTestLogger: usageLogService.abTesting,
                  testsToEvaluate: AuthenticatedABTestingService.testsToEvaluate,
                  cache: userSettings)
        await withCheckedContinuation({ continuation in
            self.setupAuthenticatedTesting {
                continuation.resume()
            }
        })
    }
}
