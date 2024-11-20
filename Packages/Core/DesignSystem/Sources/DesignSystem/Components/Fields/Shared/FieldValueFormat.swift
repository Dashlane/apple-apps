import Foundation
import SwiftUI

public enum FieldValueFormat: Equatable {
  public enum AccountIdentifier: Equatable {
    case bic
    case iban
  }
  case accountIdentifier(AccountIdentifier)
  case cardNumber
}
