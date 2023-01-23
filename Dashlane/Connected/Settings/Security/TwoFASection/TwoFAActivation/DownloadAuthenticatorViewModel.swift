import Foundation
import SwiftTreats
import AuthenticatorKit

class DownloadAuthenticatorViewModel: ObservableObject {
    @Published
    var isLoading: Bool = false

    let viewer = AppStoreProductViewer(identifier: .authenticator)

    let showAppStorePage: (AppStoreProductViewer) -> Void
    init(showAppStorePage: @escaping (AppStoreProductViewer) -> Void) {
        self.showAppStorePage = showAppStorePage
    }

    func openAppStoreView() {

        #if targetEnvironment(simulator)
                assertionFailure()
        #endif
        guard !isLoading else { return }
        isLoading = true
        Task {
            try? await viewer.prepareAppStorePage()
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.isLoading = false
                self.showAppStorePage(self.viewer)
                var sharedDefault = SharedUserDefault<Bool?, String>(key: AuthenticatorUserDefaultKey.show2FAOnboarding.rawValue)
                sharedDefault.wrappedValue = true
            }
        }
    }
}
