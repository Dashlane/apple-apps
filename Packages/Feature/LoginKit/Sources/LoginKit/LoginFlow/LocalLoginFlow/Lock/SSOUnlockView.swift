#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import DashTypes
  import CoreLocalization
  import DesignSystem
  import UIComponents

  public struct SSOUnlockView: View {

    @StateObject
    var model: SSOUnlockViewModel

    public init(model: @autoclosure @escaping () -> SSOUnlockViewModel) {
      self._model = .init(wrappedValue: model())
    }

    public var body: some View {
      ZStack {
        introView
        if model.inProgress {
          ProgressView()
        } else if let ssoAuthenticationInfo = model.ssoAuthenticationInfo {
          SSOLocalLoginView(
            model: model.makeSSOLoginViewModel(ssoAuthenticationInfo: ssoAuthenticationInfo))
        }
      }
      .animation(.default, value: model.inProgress)
      .onAppear {
        model.logOnAppear()
      }
    }

    var introView: some View {
      VStack {
        LoginLogo(login: model.login)
        Spacer()
          .frame(maxHeight: .infinity)
        Button(L10n.Core.unlockWithSSOTitle) {
          model.unlock()
        }
        .buttonStyle(.designSystem(.titleOnly))
        .padding()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          NavigationBarButton(
            action: model.logout,
            title: L10n.Core.kwLogOut
          )
        }
      }
    }
  }

  #Preview {
    SSOUnlockView(model: .mock)
  }
#endif
