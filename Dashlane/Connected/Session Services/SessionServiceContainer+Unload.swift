import Foundation
import Combine
import DashlaneAppKit
import LoginKit

extension SessionServicesContainer {

    func unload(reason: SessionServicesUnloadReason) {
        authenticatorAppCommunicator.unload()
        todayExtensionCommunicator.unload()
        watchAppCommunicator.unload()
        autofillService.unload(reason: reason)
        premiumService.unload(reason: reason)
        documentStorageService.unload()
        activityReporter.unload(reason: reason)
        syncService.unload {}
        vaultItemsService.unload(reason: reason)
        appServices.deepLinkingService.unload()
        if reason == .userLogsOut {
            IdentityDashboardWidgetService.clear()
        }
        #if targetEnvironment(macCatalyst)
        appServices.safariExtensionService.unload()
        #endif
    }
}
