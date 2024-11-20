import DesignSystem
import SwiftUI

@MainActor
struct ObfuscatedDisplayFieldsView: View {
  enum ViewConfiguration: String {
    case lightAppearance
    case darkAppearance
    case smallestDynamicTypeSize
    case largeDynamicTypeSize
  }

  var viewConfiguration: ViewConfiguration? {
    guard
      let configuration = ProcessInfo.processInfo.environment[
        "obfuscatedDisplayFieldsConfiguration"]
    else { return nil }
    return ViewConfiguration(rawValue: configuration)
  }

  var body: some View {
    switch viewConfiguration {
    case .lightAppearance:
      commonView
        .preferredColorScheme(.light)
    case .darkAppearance:
      commonView
        .preferredColorScheme(.dark)
    case .smallestDynamicTypeSize:
      commonView
        .dynamicTypeSize(.xSmall)
    case .largeDynamicTypeSize:
      commonView
        .dynamicTypeSize(.accessibility1)
    case .none:
      EmptyView()
    }
  }

  private var commonView: some View {
    List {
      ObfuscatedDisplayField(
        "Credit Card",
        value: "30326387404372",
        format: .cardNumber
      ) {
        FieldAction.CopyContent {}
      }

      ObfuscatedDisplayField(
        "IBAN",
        value: "FR6312739000506113365383Z85",
        format: .accountIdentifier(.iban)
      ) {
        FieldAction.CopyContent {}
      }

      ObfuscatedDisplayField(
        "BIC",
        value: "CPPTFRP1",
        format: .accountIdentifier(.bic)
      ) {
        FieldAction.CopyContent {}
      }
    }
    .textFieldRevealSecureValue(true)
  }
}

#Preview {
  ObfuscatedDisplayFieldsView()
}
