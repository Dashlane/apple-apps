import CoreLocalization
import CoreTypes
import Foundation
import LogFoundation
import SwiftTreats
import SwiftUI

private struct CopyErrorMessageModifier: ViewModifier {
  let errorMessage: String?

  func body(content: Content) -> some View {
    content
      .overlay(
        alignment: .bottom,
        content: {
          if let errorMessage = errorMessage, DiagnosticMode.isEnabled {
            CopyErrorButton(errorMessage: errorMessage)
              .offset(y: 30)
          }
        })
  }
}

extension View {
  func copyErrorMessageAction(errorMessage: String?) -> some View {
    self.modifier(CopyErrorMessageModifier(errorMessage: errorMessage))
  }
}

private struct CopyErrorButton: View {
  @Environment(\.toast) var toast

  let errorMessage: String

  var body: some View {
    Button(CoreL10n.copyError) {
      UIPasteboard.general.string = errorMessage
      self.toast(CoreL10n.copyErrorConfirmation)
    }
  }
}
