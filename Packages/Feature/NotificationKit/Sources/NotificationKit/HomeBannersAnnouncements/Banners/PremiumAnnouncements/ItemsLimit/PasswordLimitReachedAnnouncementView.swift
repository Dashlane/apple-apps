import CoreLocalization
import DesignSystem
import SwiftUI

public struct PasswordLimitReachedAnnouncementView: View {
  let action: () -> Void

  public init(action: @escaping () -> Void) {
    self.action = action
  }

  public var body: some View {
    Infobox(CoreL10n.premiumPasswordLimitReachedTitle) {
      Button(CoreL10n.premiumPasswordLimitReachedAction) {
        action()
      }
    }
    .style(mood: .warning)
  }
}

#Preview {
  PasswordLimitReachedAnnouncementView(action: {})
}
