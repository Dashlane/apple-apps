import Foundation
import SwiftUI

struct TextStyleKey: EnvironmentKey {
  static let defaultValue: TextStyle? = nil
}

extension EnvironmentValues {
  var textStyle: TextStyle? {
    get { self[TextStyleKey.self] }
    set { self[TextStyleKey.self] = newValue }
  }
}
