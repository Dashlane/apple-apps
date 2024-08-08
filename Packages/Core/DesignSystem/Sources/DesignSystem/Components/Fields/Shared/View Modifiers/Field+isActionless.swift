import Foundation
import SwiftUI

enum FieldActionlessKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
  var isFieldActionless: Bool {
    get { self[FieldActionlessKey.self] }
    set { self[FieldActionlessKey.self] = newValue }
  }
}

extension View {
  func actionlessField(_ isActionless: Bool = true) -> some View {
    environment(\.isFieldActionless, isActionless)
  }
}
