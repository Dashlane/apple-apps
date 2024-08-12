import Combine
import CoreFeature
import CoreSession
import CoreSettings
import DashTypes
import DashlaneAPI
import Foundation

extension AuthenticatedABTestingService {

  convenience init(
    userSettings: UserSettings,
    logger: Logger,
    login: Login,
    loadingContext: SessionLoadingContext,
    authenticatedAPIClient: UserDeviceAPIClient
  ) async {
    await self.init(
      logger: logger,
      userEmail: login.email,
      authenticatedAPIClient: authenticatedAPIClient,
      fetchingStrategy: loadingContext.isFirstLogin ? .atInit : .background,
      testsToEvaluate: AuthenticatedABTestingService.testsToEvaluate,
      cache: userSettings)
  }
}
