import Foundation
import SwiftUI
import UIDelight
import CoreSession
import StoreKit
import TOTPGenerator
import AuthenticatorKit

struct PairedView<Content: View>: View {

    @StateObject
    var model: PairedViewModel

    @Binding
    var showAnnouncement: Bool

    let announcementContent: () -> Content
    
    @State
    var isInBackGround = false
    
    init(model: @autoclosure @escaping () -> PairedViewModel,
         showAnnouncement: Binding<Bool>,
         @ViewBuilder announcementContent: @escaping () -> Content) {
        _model = .init(wrappedValue: model())
        _showAnnouncement = showAnnouncement
        self.announcementContent = announcementContent
    }
    
    var body: some View {
        content
            .sheet(item: $model.displayedSheet, onDismiss: nil) { sheet in
                switch sheet {
                case .addItem:
                    AddItemFlowView(viewModel: model.makeAddItemRootViewModel())
                case let .addItemViaCameraApp(otpInfo):
                    AddItemScanCodeFlowView(viewModel: model.makeAddItemScanCodeFlowViewModel(otpInfo: otpInfo, isFirstToken: model.codes.isEmpty))
                }
            }
            .onOpenURL { url in
                guard let config = try? OTPConfiguration(otpURL: url, supportDashlane2FA: true) else {
                    return
                }
                model.displayedSheet = .addItemViaCameraApp(OTPInfo(configuration: config))
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                                if isInBackGround {
                    model.lock = .secure
                    isInBackGround = false
                } else if model.lock != .secure {
                    model.lock = nil
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                isInBackGround = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                if model.lock != .secure {
                    model.lock = .privacyShutter
                }
            }
            .globalFullScreen(lock: $model.lock) { lock in
                switch lock {
                case .privacyShutter:
                    PrivacyLock()
                case .secure:
                    UnlockView(model: model.makeUnlockViewModel())
                case .none:
                    EmptyView()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if model.isLoading {
            AccountLoadingView()
        } else if model.codes.isEmpty {
            IntroView(isStandAlone: false) { _ in
                self.model.displayedSheet = .addItem()
            }
        } else {
            NavigationView {
                TokenListView(model: model.makeTokenListViewModel(),
                              expandedToken: $model.lastCodeAdded,
                              addAction: { skipIntro in self.model.displayedSheet = .addItem(skipIntro) },
                              showAnnouncement: $showAnnouncement,
                              announcementContent: announcementContent)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        guard !ProcessInfo.isTesting else {
                            return
                        }
                        if model.requestRating, let windowScene = UIApplication.shared.windows.first?.windowScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                            model.didFinishRating()
                        }
                    }
                }
            }
        }
    }
}
