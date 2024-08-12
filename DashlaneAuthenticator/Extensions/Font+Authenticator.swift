import Foundation
import SwiftUI
import UIComponents

extension Font {

  enum Authenticator {
    case largeTitle
    case mediumTitle

    var font: Font {
      switch self {
      case .largeTitle:
        return .custom(
          GTWalsheimPro.regular.name,
          size: 34,
          relativeTo: .title
        )
        .weight(.medium)
      case .mediumTitle:
        return .custom(
          GTWalsheimPro.regular.name,
          size: 28,
          relativeTo: .title
        )
        .weight(.medium)
      }
    }
  }

  static func authenticator(_ authenticator: Authenticator) -> Font {
    return authenticator.font
  }
}
