import SwiftUI

extension Button where Label == Text {
  public init(action: @escaping () -> Void, title: String) {
    self.init(
      action: action,
      label: {
        Text(title)
      })
  }
}
