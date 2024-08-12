import SwiftUI

extension View {
  @ViewBuilder
  public func disableHeaderCapitalization() -> some View {
    self.textCase(nil)
  }
}
