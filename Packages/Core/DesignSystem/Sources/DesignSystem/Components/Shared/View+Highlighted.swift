import Foundation
import SwiftUI

extension EnvironmentValues {
  @Entry var isHighlighted: Bool = false
}

extension View {
  public func highlighted(_ highlighted: Bool = true) -> some View {
    environment(\.isHighlighted, highlighted)
  }
}
