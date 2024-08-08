import Combine
import CoreSession
import Foundation

extension SessionServicesContainer {

  func unload(reason: SessionServicesUnloadReason) async {
    if reason == .userLogsOut {
      notificationService.unload()
    }
    authenticatorAppCommunicator.unload()
    todayExtensionCommunicator.unload()
    watchAppCommunicator.unload()
    documentStorageService.unload()
    activityReporter.unload(reason: reason)
    await syncService.unload()
    vaultServicesSuit.unload(reason: reason)
    appServices.deepLinkingService.unload()
    if reason == .userLogsOut {
      IdentityDashboardWidgetService.clear()
      await autofillService.unload()
    }
  }
}
