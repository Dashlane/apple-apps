import Foundation
import CorePersonalData
import SwiftUI
import CoreLocalization

extension BankAccount: VaultItem {
    public var enumerated: VaultItemEnumeration {
        .bankAccount(self)
    }

    public var localizedTitle: String {
        guard !name.isEmpty else {

            if let bank = bank, !bank.name.isEmpty {
                return bank.name
            }

            return L10n.Core.kwBankStatementIOS
        }
        return name
    }

    public var localizedSubtitle: String {
        guard !owner.isEmpty else {
            return L10n.Core.KWBankStatementIOS.bankAccountOwner
        }
        return owner
    }

    public static var localizedName: String {
        L10n.Core.kwBankStatementIOS
    }

    public static var addTitle: String {
        L10n.Core.kwadddatakwBankStatementIOS
    }

    public static var nativeMenuAddTitle: String {
        L10n.Core.addBankAccount
    }
}

extension BankAccount: CopiablePersonalData {

    public var valueToCopy: String {
        iban
    }

    public var fieldToCopy: DetailFieldType {
        return .bankAccountIBAN
    }
}
