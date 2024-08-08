#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import SwiftTreats
  import CoreLocalization
  import DashTypes

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
      Button(
        action: {
          UIPasteboard.general.string = errorMessage
          self.toast(L10n.Core.copyErrorConfirmation)
        }, title: L10n.Core.copyError)
    }
  }
#endif
