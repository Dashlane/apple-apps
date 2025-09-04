import CoreLocalization
import DesignSystem
import DesignSystemExtra
import SwiftUI
import UIDelight

struct SecurityAuthTokenAlert: View {
  @Environment(\.dismiss) var dismiss
  let token: String

  var body: some View {
    NativeAlert {
      VStack(spacing: 16) {
        Text(CoreL10n.kwTokenPlaceholderText)
          .font(.headline)

        Text(token, format: .securityCode)
          .font(.system(size: 42, weight: .semibold).monospacedDigit())
          .kerning(4)
          .foregroundStyle(Color.ds.text.positive.standard)
      }
      .padding(16)
    } buttons: {
      Button(CoreL10n.kwDoneButton) {
        dismiss()
      }
    }
    .shadow(radius: 32)
  }
}

#Preview {
  SecurityAuthTokenAlert(token: "123456")
}
