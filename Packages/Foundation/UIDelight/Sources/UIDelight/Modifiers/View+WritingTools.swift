import SwiftUI

extension View {
  @ViewBuilder
  public func writingToolsDisabled(_ disabled: Bool = true) -> some View {
    if #available(iOS 18.0, macOS 15.0, visionOS 2.4, *) {
      self.writingToolsBehavior(disabled ? .disabled : .automatic)
    } else {
      self
    }
  }
}
