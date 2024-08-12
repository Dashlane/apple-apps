import SwiftUI

extension View {
  public func eraseToAnyView() -> AnyView {
    return AnyView(self)
  }
}
