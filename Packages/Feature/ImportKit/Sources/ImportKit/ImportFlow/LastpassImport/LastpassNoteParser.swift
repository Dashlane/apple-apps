import Foundation
import CorePersonalData
import CSVParser
import VaultKit

struct LastpassNoteParser {

    fileprivate static let monthFormatter: DateFormatter = {
        let dateFormatter  = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter
    }()

    enum LastpassNoteType {
        case creditCard(CreditCard)
        case bankAccount(BankAccount)
    }

    private enum Header: String {
        case type = "NoteType:"
    }

    private enum NoteTypeValue: String {
        case bankAccount = "Bank Account"
        case creditCard = "Credit Card"
    }

    fileprivate enum CreditCardHeader: String, CaseIterable {
        case language = "Language:"
        case ownerName = "Name on Card:"
        case cardType = "Type:"
        case cardNumber = "Number:"
        case securityCode = "Security Code:"
        case startDate = "Start Date:"
        case endDate = "Expiration Date:"
        case note = "Notes:"
    }

    fileprivate enum BankAccountHeader: String, CaseIterable {
        case language = "Language:"
        case bankName = "Bank Name:"
        case account = "Account Type:"
        case routingNumber = "Routing Number:"
        case accountNumber = "Account Number:"
        case swiftCode = "SWIFT Code:"
        case iban = "IBAN Number:"
        case pin = "Pin:"
        case address = "Branch Address:"
        case phone = "Branch Phone:"
    }

    static func parse(item: LastpassItem) -> LastpassNoteType? {
        guard item.extra.hasPrefix(LastpassNoteParser.Header.type.rawValue) else { return nil }
        var noteContent = item.extra.split(separator: "\n")
        let noteType = noteContent
            .removeFirst()
            .deletingPrefix(Header.type.rawValue)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return parse(lines: noteContent, noteType: noteType)
    }

    private static func parse(
        lines: [String.SubSequence],
        noteType: String
    ) -> LastpassNoteType? {

        switch noteType {
        case NoteTypeValue.bankAccount.rawValue:
            var result: [String: String] = [:]
            lines.forEach { line in
                if let header = BankAccountHeader.allCases.map(\.rawValue).first(where: { line.hasPrefix($0) }) {
                    let value = line
                        .deletingPrefix(header)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    result[header] = value
                } else {
                                        result[CreditCardHeader.note.rawValue]?.append(contentsOf: "\n" + line)
                }
            }
            if let bankAccount = BankAccount.create(from: result) {
                return .bankAccount(bankAccount)
            } else {
                return nil
            }

        case NoteTypeValue.creditCard.rawValue:
            var result: [String: String] = [:]
            lines.forEach { line in
                if let header = CreditCardHeader.allCases.map(\.rawValue).first(where: { line.hasPrefix($0) }) {
                    let value = line
                        .deletingPrefix(header)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    result[header] = value
                } else {
                                        result[CreditCardHeader.note.rawValue]?.append(contentsOf: "\n" + line)
                }
            }
            if let creditCard = CreditCard.create(from: result) {
                return .creditCard(creditCard)
            } else {
                return nil
            }
        default:
                        return nil
        }
    }
}

private extension String.SubSequence {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return String(self) }
        return String(self.dropFirst(prefix.count))
    }
}

private extension CreditCard {
    static func create(from dic: [String: String]) -> CreditCard? {
        guard let ownerName = dic[LastpassNoteParser.CreditCardHeader.ownerName.rawValue],
              let cardNumber = dic[LastpassNoteParser.CreditCardHeader.cardNumber.rawValue]
        else { return nil }
        let endDate = dic[LastpassNoteParser.CreditCardHeader.endDate.rawValue]
        let startDate = dic[LastpassNoteParser.CreditCardHeader.startDate.rawValue]
        let cardType = dic[LastpassNoteParser.CreditCardHeader.cardType.rawValue]
        let notes = dic[LastpassNoteParser.CreditCardHeader.note.rawValue]
        let securityCode = dic[LastpassNoteParser.CreditCardHeader.securityCode.rawValue]

        var creditCard = CreditCard()
        creditCard.cardNumber = cardNumber
        creditCard.ownerName = ownerName
        creditCard.securityCode = securityCode ?? ""
        creditCard.note = notes ?? ""
        creditCard.name = cardType ?? ownerName
        if let endDateComponents = endDate?.split(separator: ","),
           let endMonthName = endDateComponents.first,
           let endMonthDate = LastpassNoteParser.monthFormatter.date(from: String(endMonthName)),
           let endYear = endDateComponents.last {
            creditCard.expireMonth = Calendar.current.dateComponents([.month], from: endMonthDate).month
            creditCard.expireYear = Int(endYear)
        }
        if let startDateComponents = startDate?.split(separator: ","),
           let startMonthName = startDateComponents.first,
           let startMonthDate = LastpassNoteParser.monthFormatter.date(from: String(startMonthName)),
           let startYear = startDateComponents.last {
            creditCard.startMonth = Calendar.current.dateComponents([.month], from: startMonthDate).month
            creditCard.startYear = Int(startYear)
        }

        return creditCard
    }
}

private extension BankAccount {
    static func create(from dic: [String: String]) -> BankAccount? {
        guard let iban = dic[LastpassNoteParser.BankAccountHeader.iban.rawValue],
              let bankName = dic[LastpassNoteParser.BankAccountHeader.bankName.rawValue],
              let swiftCode = dic[LastpassNoteParser.BankAccountHeader.swiftCode.rawValue]
        else { return nil }
        let accountNumber = dic[LastpassNoteParser.BankAccountHeader.accountNumber.rawValue]

        var bankAccount = BankAccount()
        bankAccount.iban = iban
        bankAccount.name = bankName
        bankAccount.bic = swiftCode
        bankAccount.owner = accountNumber ?? ""
        return bankAccount
    }
}
