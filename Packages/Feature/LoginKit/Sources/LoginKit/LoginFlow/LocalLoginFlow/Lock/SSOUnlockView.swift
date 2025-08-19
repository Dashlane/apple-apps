import CoreLocalization
import CoreTypes
import DesignSystem
import Foundation
import SwiftUI
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
      if let viewState = model.viewState {
        switch viewState {
        case let .ssoLogin(initialState, ssoAuthenticationInfo, deviceAccessKey):
          SSOLocalLoginView(
            model: model.makeSSOLoginViewModel(
              initialState: initialState, ssoAuthenticationInfo: ssoAuthenticationInfo,
              deviceAccessKey: deviceAccessKey)
          )
          .reportPageAppearance(.unlock)
        case .inProgress:
          ProgressView()
            .progressViewStyle(.indeterminate)
        }
      }
    }
    .animation(.default, value: model.inProgress)
  }

  var introView: some View {
    VStack {
      LoginLogo(login: model.login)
      if let errorMessage = model.errorMessage {
        Spacer()
        Text(errorMessage)
      }
      Spacer()
        .frame(maxHeight: .infinity)
      Button(CoreL10n.unlockWithSSOTitle) {
        model.unlock()
      }
      .buttonStyle(.designSystem(.titleOnly))
      .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(CoreL10n.kwLogOut) {
          Task {
            await model.logout()
          }
        }
      }
    }
  }
}

#Preview {
  SSOUnlockView(model: .mock)
}
