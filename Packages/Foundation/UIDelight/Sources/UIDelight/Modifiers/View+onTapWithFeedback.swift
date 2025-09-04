import Foundation
import SwiftUI

extension View {
  @ViewBuilder
  public func onTapWithFeedback(perform action: @escaping () -> Void) -> some View {
    #if targetEnvironment(macCatalyst)
      Button(
        action: action,
        label: {
          self
            .contentShape(Rectangle())
        }
      )
      .buttonStyle(DefaultButtonStyle())
      .foregroundStyle(.primary)

    #else
      Button(
        action: action,
        label: {
          self
            .contentShape(Rectangle())
        }
      ).foregroundStyle(.primary)
    #endif

  }
}
