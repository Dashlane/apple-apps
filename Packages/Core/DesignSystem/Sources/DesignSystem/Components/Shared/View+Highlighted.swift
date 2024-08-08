import Foundation
import SwiftUI

enum HighlightedKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
  public var isHighlighted: Bool {
    get { self[HighlightedKey.self] }
    set { self[HighlightedKey.self] = newValue }
  }
}

extension View {
  public func highlighted(_ highlighted: Bool = true) -> some View {
    environment(\.isHighlighted, highlighted)
  }
}
