import Foundation
import SwiftUI

extension Label where Title == EmptyView, Icon == Image {
  public init(icon: Image) {
    self.init(
      title: { EmptyView() },
      icon: { icon.resizable() }
    )
  }
}

extension Label where Title == Text, Icon == Image {
  public init<S: StringProtocol>(_ title: S, icon: Image) {
    self.init(
      title: { Text(title) },
      icon: { icon.resizable() }
    )
  }
}
