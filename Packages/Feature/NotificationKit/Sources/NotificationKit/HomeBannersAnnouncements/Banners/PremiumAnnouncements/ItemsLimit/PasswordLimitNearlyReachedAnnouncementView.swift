import CoreLocalization
import DesignSystem
import SwiftUI

public struct PasswordLimitNearlyReachedAnnouncementView: View {
  let remainingItems: Int
  let action: () -> Void

  public init(
    remainingItems: Int,
    action: @escaping () -> Void
  ) {
    self.remainingItems = remainingItems
    self.action = action
  }

  public var body: some View {
    Infobox(title) {
      Button(CoreL10n.premiumPasswordLimitNearlyReachedAction) {
        action()
      }
    }
    .style(mood: .brand)
  }

  var title: String {
    if remainingItems > 1 {
      CoreL10n.premiumPasswordLimitNearlyReachedTitle(remainingItems)
    } else {
      CoreL10n.premiumPasswordLimitNearlyReachedTitleSingular
    }
  }
}

#Preview("w/o remaining items") {
  PasswordLimitNearlyReachedAnnouncementView(remainingItems: 0, action: {})
}

#Preview("w/ remaining items") {
  PasswordLimitNearlyReachedAnnouncementView(remainingItems: 2, action: {})
}
