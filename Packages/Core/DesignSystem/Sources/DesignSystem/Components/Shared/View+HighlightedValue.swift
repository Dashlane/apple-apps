import Foundation
import SwiftUI

extension EnvironmentValues {
  @Entry public var highlightedValue: String?
}

extension View {
  public func highlightedValue(_ value: String?) -> some View {
    environment(\.highlightedValue, value.flatMap { $0.isEmpty ? nil : $0 })
  }
}
