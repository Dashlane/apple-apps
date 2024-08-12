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
      Button(L10n.Core.premiumPasswordLimitNearlyReachedAction) {
        action()
      }
    }
    .style(mood: .brand)
  }

  var title: String {
    if remainingItems > 1 {
      L10n.Core.premiumPasswordLimitNearlyReachedTitle(remainingItems)
    } else {
      L10n.Core.premiumPasswordLimitNearlyReachedTitleSingular
    }
  }
}

#Preview("w/o remaining items") {
  PasswordLimitNearlyReachedAnnouncementView(remainingItems: 0, action: {})
}

#Preview("w/ remaining items") {
  PasswordLimitNearlyReachedAnnouncementView(remainingItems: 2, action: {})
}
