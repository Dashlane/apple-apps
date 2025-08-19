import SwiftUI

extension EdgeInsets {
  public static func field(isLabelVisible: Bool) -> EdgeInsets {
    return EdgeInsets(
      top: isLabelVisible ? 8 : 4,
      leading: 16,
      bottom: isLabelVisible ? 8 : 4,
      trailing: 0
    )
  }

  public var vertical: Double { top + bottom }
}
