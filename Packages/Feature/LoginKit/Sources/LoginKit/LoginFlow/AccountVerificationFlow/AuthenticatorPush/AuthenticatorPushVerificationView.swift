#if canImport(UIKit)
  import SwiftUI
  import DashTypes
  import UIDelight
  import UIComponents
  import DesignSystem
  import CoreLocalization

  public struct AuthenticatorPushVerificationView: View {

    @ObservedObject
    public var model: AuthenticatorPushVerificationViewModel

    @Environment(\.dismiss)
    private var dismiss

    private let fallbackOptionTitle: String

    public init(
      model: AuthenticatorPushVerificationViewModel,
      fallbackOptionTitle: String = L10n.Core.authenticatorPushViewSendTokenButtonTitle
    ) {
      self.model = model
      self.fallbackOptionTitle = fallbackOptionTitle
    }

    public var body: some View {
      authenticatorPushView
        .navigationTitle(L10n.Core.kwLoginVcLoginButton)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            NavigationBarButton(
              action: dismiss.callAsFunction,
              title: L10n.Core.kwBack)
          }
        }
    }

    private var authenticatorPushView: some View {
      GravityAreaVStack(
        top: LoginLogo(login: model.login),
        center: center,
        bottom: bottomView,
        spacing: 0
      )
      .loginAppearance()
      .onAppear {
        Task {
          await self.model.sendAuthenticatorPush()
        }
      }
    }

    private var bottomView: some View {
      VStack(spacing: 23) {
        if model.showRetry {
          Button(L10n.Core.authenticatorPushRetryButtonTitle) {
            Task {
              await model.sendAuthenticatorPush()
            }
          }
          .buttonStyle(.designSystem(.titleOnly))
        }
        Button(action: { model.showToken() }, title: fallbackOptionTitle)
          .foregroundColor(.ds.text.brand.standard)
          .padding(5)
          .padding(.bottom, 40)
      }
      .padding(.horizontal, 24)
    }

    private var center: some View {
      VStack(spacing: 25) {
        Group {
          if model.inProgress {
            LottieView(.passwordChangerLoading)
          } else {
            if model.isSuccess {
              LottieView(.passwordChangerSuccess, loopMode: .playOnce)
            } else {
              LottieView(.passwordChangerFail, loopMode: .playOnce)
            }
          }
        }
        .frame(width: 62, height: 62, alignment: .center)
        messageView
      }
      .padding(.horizontal, 24)
    }

    private var messageView: some View {
      Text(model.message)
        .font(.headline)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .foregroundColor(.ds.text.brand.standard)
    }
  }

  struct AuthenticatorPushView_Previews: PreviewProvider {
    static var previews: some View {
      AuthenticatorPushVerificationView(
        model: AuthenticatorPushVerificationViewModel(
          login: Login("_"), accountVerificationService: .mock, completion: { _ in }))
    }
  }
#endif
