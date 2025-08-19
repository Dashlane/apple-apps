import SwiftUI

extension View {
  @available(*, deprecated, message: "Remove alongside UINavigationController.")
  public func navigationBarVisible() -> some View {
    self
      .toolbar(.visible, for: .navigationBar)
  }
}
