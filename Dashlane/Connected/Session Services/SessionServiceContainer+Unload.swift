import Foundation
import Combine
import DashlaneAppKit
import CoreSession

extension SessionServicesContainer {

    func unload(reason: SessionServicesUnloadReason) {
        authenticatorAppCommunicator.unload()
        todayExtensionCommunicator.unload()
        watchAppCommunicator.unload()
        premiumService.unload(reason: reason)
        documentStorageService.unload()
        activityReporter.unload(reason: reason)
        syncService.unload {}
        vaultItemsService.unload(reason: reason)
        appServices.deepLinkingService.unload()
        if reason == .userLogsOut {
            IdentityDashboardWidgetService.clear()
            autofillService.unload()
        }
        #if targetEnvironment(macCatalyst)
        appServices.safariExtensionService.unload()
        #endif
    }
}
