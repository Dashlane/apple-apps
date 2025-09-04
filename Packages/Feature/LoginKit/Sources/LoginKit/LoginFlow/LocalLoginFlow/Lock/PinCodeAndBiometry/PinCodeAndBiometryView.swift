import Combine
import CoreLocalization
import CoreSession
import CoreTypes
import DesignSystem
import DesignSystemExtra
import Foundation
import SwiftUI
import UIComponents
import UIDelight

public struct PinCodeAndBiometryView: View {
  @StateObject
  var model: PinCodeAndBiometryViewModel

  public init(model: @autoclosure @escaping () -> PinCodeAndBiometryViewModel) {
    self._model = .init(wrappedValue: model())
  }

  public var body: some View {
    VStack(alignment: .center) {
      LoginLogo(login: model.login)
        .fixedSize(horizontal: false, vertical: true)
      content
      if model.accountType.canFallbackFromPinCode {
        Button(CoreL10n.Unlock.Pincode.forgotButton) {
          Task {
            await model.perform(.recover)
          }
        }
        .style(mood: .brand, intensity: .supershy)
        .buttonStyle(.designSystem(.titleOnly))
        .padding(.horizontal)
        .disabled(self.model.isPerformingEvent)
      }
    }
    .loginAppearance()
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        NativeNavigationBarBackButton(CoreL10n.kwBack) {
          Task {
            await model.perform(.cancel)
          }
        }
      }
    }
  }

  @ViewBuilder
  var content: some View {
    switch model.viewState {
    case .biometry(let biometryType):
      Spacer()
      Image(biometry: biometryType)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 58, height: 58)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .onAppear {
          Task {
            await model.validateBiometry()
          }
        }
      Spacer()
        .reportPageAppearance(.unlockBiometric)
    case .pin:
      PinCodeView(
        pinCode: $model.pincode,
        length: model.pincodeLength,
        attempt: model.attempts,
        hideCancel: true,
        cancelAction: {}
      )
      .frame(maxHeight: .infinity)
      .padding(.bottom, 30)
      .padding(.horizontal, 40)
      .reportPageAppearance(.unlockPin)
    case .none:
      EmptyView()
    }
  }
}

#Preview {
  PinCodeAndBiometryView(model: .mock)
}

extension AccountType {
  fileprivate var canFallbackFromPinCode: Bool {
    switch self {
    case .masterPassword:
      return false
    case .invisibleMasterPassword:
      return true
    case .sso:
      return false
    }
  }
}
