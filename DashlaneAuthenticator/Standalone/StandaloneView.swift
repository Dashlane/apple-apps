import Foundation
import SwiftUI
import UIDelight
import Combine
import StoreKit
import TOTPGenerator
import AuthenticatorKit
import SwiftTreats

enum StandaloneViewSheet: Identifiable {
    case addItem(_ skipIntro: Bool = false)
    case downloadDashlane
    case addItemViaCameraApp(OTPInfo)

    var id: String {
        switch self {
        case .addItem:
            return "addItem"
        case .downloadDashlane:
            return "downloadDashlane"
        case .addItemViaCameraApp:
            return "addItemViaCameraApp"
        }
    }
}

struct StandaloneView<Content: View>: View {

    @StateObject
    var model: StandaloneViewModel

    @Binding
    var showAnnouncement: Bool

    let announcementContent: () -> Content

    let refreshPairingAnnouncement = PassthroughSubject<Void, Never>()

    init(model: @autoclosure @escaping () -> StandaloneViewModel,
         showAnnouncement: Binding<Bool>,
         @ViewBuilder announcementContent: @escaping () -> Content) {
        _model = .init(wrappedValue: model())
        _showAnnouncement = showAnnouncement
        self.announcementContent = announcementContent
    }

    @State var appStoreViewer: AppStoreProductViewer?

    var body: some View {
        ZStack {
            if model.codes.isEmpty && model.showOnboarding {
                IntroView(isStandAlone: true) { action in
                    switch action {
                    case .add:
                        self.model.displayedSheet = .addItem()
                        model.finishOnboarding()
                    case .skip:
                        model.finishOnboarding()
                    }
                }
            } else {
                NavigationView {
                    TokenListView(model: model.makeTokenListViewModel(),
                                  expandedToken: $model.lastCodeAdded,
                                  addAction: { skipIntro in
                        self.model.displayedSheet = .addItem(skipIntro)
                    },
                                  showAnnouncement: .constant(true),
                                  announcementContent: { announcementDisplayed })
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            guard !ProcessInfo.isTesting else {
                                return
                            }
                            if model.requestRating, let windowScene = UIApplication.shared.keyWindowScene {
                                SKStoreReviewController.requestReview(in: windowScene)
                                model.didFinishRating()
                            }
                        }
                    }
                }
            }
        }

        .modifier(StandaloneViewSheetModifier(displayedSheet: $model.displayedSheet,
                                              makeAddItemRootViewModel: model.makeAddItemRootViewModel,
                                              makeDownloadDashlaneViewModel: model.makeDownloadDashlaneViewModel,
                                              makeAddItemScanCodeFlowViewModel: { info in
            model.makeAddItemScanCodeFlowViewModel(otpInfo: info, isFirstToken: model.codes.isEmpty)
        },
                                              refreshPairingAnnouncement: refreshPairingAnnouncement))
        .onOpenURL { url in
            guard let config = try? OTPConfiguration(otpURL: url, supportDashlane2FA: true) else {
                return
            }
            model.displayedSheet = .addItemViaCameraApp(OTPInfo(configuration: config))
        }

    }

    @ViewBuilder
    var announcementDisplayed: some View {
        if self.showAnnouncement {
            announcementContent()
        } else {
            PairingStatusAnnouncement(refreshPairingAnnouncement: refreshPairingAnnouncement.eraseToAnyPublisher(),
                                      action: { action in
                switch action {
                case .installApplication:
                    self.model.displayedSheet = .downloadDashlane
                case .configureApplication:
                    UIApplication.shared.open(.securitySettings)
                }
            })

        }
    }
}

private struct StandaloneViewSheetModifier: ViewModifier {

    @Binding
    var displayedSheet: StandaloneViewSheet?

    @State
    var appStoreViewer: AppStoreProductViewer?
    let makeAddItemRootViewModel: @MainActor (Bool) -> AddItemFlowViewModel
    let makeDownloadDashlaneViewModel: @MainActor (@escaping (AppStoreProductViewer) -> Void) -> DownloadDashlaneViewModel
    let makeAddItemScanCodeFlowViewModel: @MainActor (OTPInfo) -> AddItemScanCodeFlowViewModel

    let refreshPairingAnnouncement: PassthroughSubject<Void, Never>

    func body(content: Content) -> some View {
        content
            .sheet(item: $displayedSheet,
                   onDismiss: { self.openAppStoreViewIfPossible() },
                   content: { sheet in
                switch sheet {
                case let .addItem(skipIntro):
                    AddItemFlowView(viewModel: makeAddItemRootViewModel(skipIntro))
                case let .addItemViaCameraApp(otpInfo):
                    AddItemScanCodeFlowView(viewModel: makeAddItemScanCodeFlowViewModel(otpInfo))
                case .downloadDashlane:
                    DownloadDashlaneView(model: makeDownloadDashlaneViewModel { page in
                        self.appStoreViewer = page
                                                self.displayedSheet = nil
                    })
                }
            })
    }

    func openAppStoreViewIfPossible() {
        DispatchQueue.main.async {
                        appStoreViewer?.openAppStorePage(dismissed: {
                refreshPairingAnnouncement.send()
            })
            appStoreViewer = nil
        }
    }
}

struct StandaloneView_preview: PreviewProvider {
    static var previews: some View {
        StandaloneView(model: StandaloneViewModel(services: StandAloneServicesContainer(appServices: AppServices()),
                                                  state: .noLogin,
                                                  unlock: {}), showAnnouncement: .constant(false), announcementContent: { EmptyView() })
    }
}
