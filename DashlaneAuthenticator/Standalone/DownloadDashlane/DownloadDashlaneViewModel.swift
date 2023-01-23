import Foundation
import SwiftUI
import Combine
import CoreUserTracking
import DashlaneAppKit
import DashTypes

final class DownloadDashlaneViewModel: ObservableObject, AuthenticatorServicesInjecting {
   
    @Published
    var isLoading: Bool = false
    
    let viewer = AppStoreProductViewer(identifier: .passwordManager)
    
    let showAppStorePage: (AppStoreProductViewer) -> Void
    let activityReporter: ActivityReporterProtocol
    init(activityReporter: ActivityReporterProtocol, showAppStorePage: @escaping (AppStoreProductViewer) -> Void) {
        self.activityReporter = activityReporter
        self.showAppStorePage = showAppStorePage
    }
    
    func openAppStoreView() {
        
        #if targetEnvironment(simulator)
                assertionFailure()
        #endif
        guard !isLoading else { return }
        isLoading = true
        logPasswordAppDownload()
        Task {
            try? await viewer.prepareAppStorePage()
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.isLoading = false
                self.showAppStorePage(self.viewer)
            }
        }
    }
    
    func logPasswordAppDownload() {
        activityReporter.report(UserEvent.AuthenticatorDownloadPasswordManager())
    }
}


