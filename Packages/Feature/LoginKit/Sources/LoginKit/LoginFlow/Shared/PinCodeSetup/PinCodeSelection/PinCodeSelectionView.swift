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

  public init(model: @autoclosure @escaping () -> PinCodeSelectionViewModel) {
    _model = .init(wrappedValue: model())
  }

  public var body: some View {
    VStack(spacing: 20) {
      Text(model.current.prompt)
        .id(model.current.prompt)
        .foregroundStyle(Color.ds.text.neutral.standard)
      PinCodeView(
        pinCode: $model.pincode, length: model.pinCodeLength, attempt: model.failedAttempts
      ) {
        self.model.cancel()
        self.dismiss()
      }
    }
    .animation(.default, value: model.current.prompt)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .loginAppearance()
  }
}

extension PinCodeSelectionViewModel.Step {
  var prompt: String {
    switch self {
    case .verify:
      return CoreL10n.kwEnterYourPinCode
    case .select:
      return CoreL10n.kwChoosePinCode
    case .confirm:
      return CoreL10n.kwConfirmPinCode
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
