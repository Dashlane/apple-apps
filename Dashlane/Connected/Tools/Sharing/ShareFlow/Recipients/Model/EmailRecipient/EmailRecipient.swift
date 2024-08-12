import Foundation
import SwiftUI

struct EmailRecipient: Hashable, Identifiable {
  enum Origin {
    case sharing
    case systemContact
    case searchField
  }

  let label: String?
  let email: String
  let image: Image?
  let origin: Origin

  var id: String {
    return email
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(email)
  }

  public static func == (lhs: EmailRecipient, rhs: EmailRecipient) -> Bool {
    return lhs.email == rhs.email
  }
}

extension EmailRecipient: Comparable {
  var sortingValue: String {
    return label ?? email
  }

  static func < (lhs: EmailRecipient, rhs: EmailRecipient) -> Bool {
    lhs.sortingValue.lowercased() < rhs.sortingValue.lowercased()
  }
}

extension EmailRecipient {
  enum EmailMatch: Int {
    case weak = 0
    case strong = 1
  }

  func match(_ search: String) -> EmailMatch? {
    let lowercased = email.lowercased()
    if lowercased.hasPrefix(search) || lowercased.contains("_" + search) {
      return .strong
    } else if lowercased.contains(search) {
      return .weak
    } else {
      return nil
    }
  }
}

extension EmailRecipient {
  var title: String {
    return label ?? email
  }

  var subtitle: String? {
    return label != nil ? email : nil
  }
}

struct EmailRecipientInfo: Hashable, Identifiable {
  enum Action: Hashable {
    case add
    case toggle(removable: Bool)
  }

  let recipient: EmailRecipient
  let action: Action
  var id: String {
    recipient.id
  }
}
