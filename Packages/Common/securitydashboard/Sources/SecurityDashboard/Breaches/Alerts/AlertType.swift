import Foundation

public enum AlertType: CaseIterable {

  case dataLeakAlertWithCompromisedPasswordsAndPiis
  case dataLeakAlertWithCompromisedPasswords
  case dataLeakAlertWithCompromisedPiis
  case dataLeakAlert

  case publicAlertWithCompromisedPasswordsAndPiis
  case publicAlertWithCompromisedPasswords
  case publicAlertWithCompromisedPiis
  case publicAlert

  case dataLeakAlertHiddenContent
  case dataLeakAlertDataContent

  case dataLeakAlertWithLeakedData

  var viewable: Bool {
    return self != .publicAlert && self != .publicAlertWithCompromisedPiis
  }
}

extension AlertType {
  var isDataLeakAlert: Bool {
    switch self {
    case .dataLeakAlertWithCompromisedPasswordsAndPiis,
      .dataLeakAlertWithCompromisedPasswords,
      .dataLeakAlertWithCompromisedPiis,
      .dataLeakAlert,
      .dataLeakAlertHiddenContent,
      .dataLeakAlertDataContent,
      .dataLeakAlertWithLeakedData:
      return true
    case .publicAlertWithCompromisedPasswordsAndPiis,
      .publicAlertWithCompromisedPasswords,
      .publicAlertWithCompromisedPiis,
      .publicAlert:
      return false
    }
  }
}

public enum AlertFormat {
  case `default`

  case hiddenInformation

  public init(hiddenDataLeakForFreeUsersEnabled: Bool) {
    if hiddenDataLeakForFreeUsersEnabled {
      self = .hiddenInformation
    } else {
      self = .default
    }
  }
}
