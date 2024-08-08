import CoreLocalization
import DesignSystem
import Foundation
import SwiftUI
import UIComponents

public struct PinCodeSelection: View {

  @StateObject
  var model: PinCodeSelectionViewModel

  @Environment(\.dismiss)
  private var dismiss

  @State
  var showChangePinLengthDialog = false

  var showChangePinLengthButton: Bool {
    if case .select = model.current {
      return true
    }
    return false
  }

  public init(model: @autoclosure @escaping () -> PinCodeSelectionViewModel) {
    _model = .init(wrappedValue: model())
  }

  public var body: some View {
    VStack(spacing: 20) {
      Text(model.current.prompt)
        .id(model.current.prompt)
      PinCodeView(
        pinCode: $model.pincode, length: model.pinCodeLength, attempt: model.failedAttempts
      ) {
        self.model.cancel()
        self.dismiss()
      }
      Button(L10n.Core.changePinLengthCta) {
        showChangePinLengthDialog = true
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .brand, intensity: .supershy)
      .buttonStyle(.designSystem(.titleOnly))
      .opacity(showChangePinLengthButton ? 1 : 0)
      .disabled(!showChangePinLengthButton)
      .confirmationDialog(
        L10n.Core.changePinLengthDialogTitle, isPresented: $showChangePinLengthDialog
      ) {
        Button(L10n.Core.changePinLengthDialogSixDigits) {
          model.pinCodeLength = 6
        }
        Button(L10n.Core.changePinLengthDialogFourDigits) {
          model.pinCodeLength = 4
        }
        Button(L10n.Core.cancel, role: .cancel) {}
      } message: {
        Text(L10n.Core.changePinLengthDialogTitle)
      }
    }
    .animation(.default, value: model.current.prompt)
    .backgroundColorIgnoringSafeArea(Color.ds.background.alternate)
  }
}

extension PinCodeSelectionViewModel.Step {
  var prompt: String {
    switch self {
    case .verify:
      return L10n.Core.kwEnterYourPinCode
    case .select:
      return L10n.Core.kwChoosePinCode
    case .confirm:
      return L10n.Core.kwConfirmPinCode
    }
  }
}

#Preview {
  PinCodeSelection(
    model: PinCodeSelectionViewModel(
      currentPin: "0000",
      completion: { _ in }
    )
  )
}
