import SwiftUI
import UIDelight
import CoreUserTracking
import CoreLocalization

struct RootView: View {

    @Environment(\.scenePhase) var scenePhase

    @StateObject
    var model: RootviewModel

    init( model: @autoclosure @escaping () -> RootviewModel) {
        self._model = .init(wrappedValue: model())
    }

    @Environment(\.toast)
    var toast

    @State
    var showErrorMessage = false

    @State
    var sheetDismissAction: AuthenticationRequest?

    var body: some View {
        mainView
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
            .onChange(of: scenePhase) { phase in
                guard let url = URL(string: "dashlane:///"), !UIApplication.shared.canOpenURL(url), phase == .active else {
                    return
                }
                model.checkForDashlanePasswordApp()
            }
    }

    @ViewBuilder
    var mainView: some View {
        ZStack {
            switch model.appState {
            case .loading:
                AccountLoadingView()
            case let .askForAuthentication(sessionLoadingInfo):
                UnlockView(
                    model: model.makeUnlockViewModel(info: sessionLoadingInfo)
                )
                .transition(.lock)
            case let .paired(services):
                PairedView(
                    model: model.makePairedViewModel(services: services),
                    showAnnouncement: $model.showAnnouncement,
                    announcementContent: announcementView
                )
                .transition(.unlock)
                .environment(\.report, .init(reporter: services.authenticatorActivityReporter))
                .environment(\.enabledFeatures, services.enabledFeatures)
            case let .standalone(services, passwordAppState):
                StandaloneView(
                    model: model.makeStandaloneViewModel(
                        services: services,
                        passwordAppState: passwordAppState
                    ),
                    showAnnouncement: $model.showAnnouncement,
                    announcementContent: announcementView
                )
                .transition(.unlock)
            }
        }
        .animation(.easeIn, value: model.appState)
        .sheet(
            item: $model.currentRequest,
            onDismiss: {
                if let request = sheetDismissAction {
                    model.pendingRequest.insert(request)
                }
            },
            content: { request in
                authenticationPushView(for: request)
                    .onAppear {
                        sheetDismissAction = request
                    }
            }
        ).onReceive(model.showWelcomeMessage) {
            toast(L10n.Localizable.welcomePushMessage, image: .ds.feedback.success.outlined)
        }
        .alert(isPresented: $showErrorMessage) {
            Alert(title: Text(L10n.Localizable.authenticatorPushViewTimeOutError),
                  dismissButton: Alert.Button.default(Text(CoreLocalization.L10n.Core.kwButtonOk)))
        }
        .toasterOn()
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    }

    @ViewBuilder
    func announcementView() -> some View {
        if let pendingRequest = model.pendingRequest.first {
            PendingAuthRequestAnnouncement(expiryDate: pendingRequest.validity.expireDate) { action in
                switch action {
                case .ignore:
                    model.pendingRequest = []
                case .show:
                    model.currentRequest = pendingRequest
                }
            }
            .padding()
        } else {
            EmptyView()
        }
    }

    func authenticationPushView(for request: AuthenticationRequest) -> AuthenticationPushView {
        AuthenticationPushView(pendingRequest: $model.pendingRequest, model: model.makeAuthenticationPushViewModel(for: request) { action in
            sheetDismissAction = nil
            guard let action = action else {
                return
            }

            switch action {
            case .accept:
                toast(L10n.Localizable.pushFeedbackMessageAccepted, image: .ds.feedback.success.outlined)
            case .reject:
                toast(L10n.Localizable.pushFeedbackMessageRejected, image: .ds.feedback.fail.outlined)
            }
        })
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(model: RootviewModel(appservices: AppServices()))
    }
}

extension AnyTransition {
    private static let lockAnimation: Animation = .easeOut(duration: 0.6)

    fileprivate static var lock: AnyTransition {
        return .asymmetric(insertion: .opacity,
                           removal: .scale(scale: 1.3).combined(with: .opacity).animation(lockAnimation))
    }

    fileprivate static var unlock: AnyTransition {
        return .asymmetric(insertion: .scale(scale: 0.7).combined(with: .opacity).animation(lockAnimation),
                           removal: .opacity)
    }
}
