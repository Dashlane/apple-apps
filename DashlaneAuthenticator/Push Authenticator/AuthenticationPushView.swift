import DesignSystem
import LoginKit
import SwiftUI
import UIComponents
import UIDelight

struct AuthenticationPushView: View {

  @Binding
  var pendingRequest: Set<AuthenticationRequest>

  @StateObject
  var model: AuthenticationPushViewModel

  @Environment(\.dismiss)
  private var dismiss

  let timer = Timer.publish(every: 1, tolerance: 0.1, on: .main, in: .default).autoconnect()

  init(
    pendingRequest: Binding<Set<AuthenticationRequest>>,
    model: @autoclosure @escaping () -> AuthenticationPushViewModel
  ) {
    self._pendingRequest = pendingRequest
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    NavigationView {
      FullScreenScrollView {
        mainView
      }
      .overlay(bottomButtons, alignment: .bottom)
      .backgroundColorIgnoringSafeArea(.ds.background.alternate)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          CloseButton {
            dismiss()
            pendingRequest.insert(model.request)
            model.completion(nil)
          }
        }
      }
      .navigation(item: $model.pushError) { error in
        errorView(for: error)
      }
      .navigationBarStyle(.transparent)
      .toolbar(.hidden, for: .navigationBar)
    }
    .onReceive(timer) { _ in
      if model.request.isExpired {
        model.pushError = .expired
      }
      if model.shouldDismiss {
        dismiss()
      }
    }
  }

  var mainView: some View {
    VStack {
      VStack(spacing: 28) {
        Image(asset: AuthenticatorAsset.pushIllustration)
        VStack(spacing: 16) {
          Text(L10n.Localizable.authenticationRequestMessage)
            .font(.authenticator(.mediumTitle))
            .foregroundColor(.ds.text.neutral.catchy)
            .multilineTextAlignment(.center)
          Text(L10n.Localizable.dashlanePushMessage)
            .font(.body)
            .foregroundColor(.ds.text.neutral.standard)
            .multilineTextAlignment(.center)

        }
      }.padding(.bottom, 28)
      Spacer()
    }.padding(.horizontal, 24)
      .padding(.bottom, 24)
  }

  var bottomButtons: some View {
    AdaptiveHStack {
      VStack(spacing: 8) {
        Button(
          action: reject,
          label: {
            Image(asset: AuthenticatorAsset.cross)
              .foregroundColor(.ds.text.inverse.catchy)
              .frame(width: 80, height: 80)
              .background(.ds.container.expressive.danger.catchy.idle)
              .clipShape(Circle())
          }
        )
        .disabled(model.inProgress)
        .opacity(model.inProgress ? 0.5 : 1)
        Text(L10n.Localizable.pushRejectButtonTitle)
          .font(.subheadline)
      }

      Spacer()
      VStack(spacing: 8) {
        Button(
          action: accept,
          label: {
            Image(asset: AuthenticatorAsset.tick)
              .foregroundColor(.ds.text.inverse.catchy)
              .frame(width: 80, height: 80)
              .background(.ds.container.expressive.positive.catchy.idle)
              .clipShape(Circle())
          }
        )
        .disabled(model.inProgress)
        .opacity(model.inProgress ? 0.5 : 1)
        Text(L10n.Localizable.pushAcceptButtonTitle)
          .font(.subheadline)
      }

    }.padding(.horizontal, 64)
      .padding(.bottom, 24)
  }

  func accept() {
    model.accept()
    pendingRequest = []
  }

  func reject() {
    model.reject()
    pendingRequest = []
  }

  func errorView(for error: AuthenticationPushViewModel.PushError) -> some View {
    FeedbackView(
      title: error == .unknown
        ? L10n.Localizable.pushErrorTitle : L10n.Localizable.pushErrorExpiredTitle,
      message: error == .unknown
        ? L10n.Localizable.pushErrorSubtitle : L10n.Localizable.pushErrorExpiredSubtitle,
      primaryButton: (
        L10n.Localizable.pushErrorButtonTitle,
        {
          pendingRequest = []
          dismiss()
          model.completion(nil)
        }
      ),
      secondaryButton: nil)
  }
}

struct AuthenticationPushView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(deviceRange: .all) {
      AuthenticationPushView(
        pendingRequest: .constant([]),
        model: AuthenticationPushViewModel(
          notificationService: NotificationServiceMock(), request: AuthenticationRequest.mock,
          completion: { _ in }))
    }
  }
}
