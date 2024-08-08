import Foundation
import SwiftUI

extension Color {
  public init(passwordChar: Character) {
    switch passwordChar {
    case let passwordChar where passwordChar.isLetter: self = .ds.text.neutral.standard
    case let passwordChar where passwordChar.isNumber: self = .ds.text.oddity.passwordDigits
    default: self = .ds.text.oddity.passwordSymbols
    }
  }
}
