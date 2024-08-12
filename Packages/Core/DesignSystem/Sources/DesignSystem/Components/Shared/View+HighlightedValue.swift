import Foundation
import SwiftUI

enum HighlightedValueKey: EnvironmentKey {
  static let defaultValue: String? = nil
}

extension EnvironmentValues {
  public var highlightedValue: String? {
    get { self[HighlightedValueKey.self] }
    set { self[HighlightedValueKey.self] = newValue }
  }
}

extension View {

  public func highlightedValue(_ value: String?) -> some View {
    environment(\.highlightedValue, value.flatMap { $0.isEmpty ? nil : $0 })
  }
}
