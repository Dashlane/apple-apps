import SwiftUI

extension Animation {
  static func textInputPlaceholderAnimation(
    in environment: EnvironmentValues
  ) -> Animation {
    if environment.fieldLabelHiddenOnFocus {
      return .spring(response: 0.3, dampingFraction: 0.72)
    }
    return .easeInOut(duration: 0.3)
  }
}
