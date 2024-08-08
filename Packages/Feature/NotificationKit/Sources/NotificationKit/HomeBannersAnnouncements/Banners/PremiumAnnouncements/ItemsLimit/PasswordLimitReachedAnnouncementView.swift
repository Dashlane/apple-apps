import CoreLocalization
import DesignSystem
import SwiftUI

public struct PasswordLimitReachedAnnouncementView: View {
  let action: () -> Void

  public init(action: @escaping () -> Void) {
    self.action = action
  }

  public var body: some View {
    Infobox(L10n.Core.premiumPasswordLimitReachedTitle) {
      Button(L10n.Core.premiumPasswordLimitReachedAction) {
        action()
      }
    }
    .style(mood: .warning)
  }
}

#Preview {
  PasswordLimitReachedAnnouncementView(action: {})
}
