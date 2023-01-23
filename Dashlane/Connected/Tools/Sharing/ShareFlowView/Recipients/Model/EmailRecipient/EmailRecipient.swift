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
    func match(_ search: String) -> Bool {
        let lowercased = email.lowercased()
        return lowercased.hasPrefix(search) || lowercased.contains("_" + search)
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
