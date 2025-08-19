import CorePersonalData
import Foundation

public struct ImportableItems {

  let credentials: [Credential]
  let secureNotes: [SecureNote]
  let creditCards: [CreditCard]
  let bankAccounts: [BankAccount]

  var isEmpty: Bool {
    return credentials.isEmpty && secureNotes.isEmpty && creditCards.isEmpty && bankAccounts.isEmpty
  }

  func vaultItems() -> [VaultItem] {
    credentials + secureNotes + creditCards + bankAccounts
  }

  public init(
    credentials: [Credential] = [],
    secureNotes: [SecureNote] = [],
    creditCards: [CreditCard] = [],
    bankAccounts: [BankAccount] = []
  ) {
    self.credentials = credentials
    self.secureNotes = secureNotes
    self.creditCards = creditCards
    self.bankAccounts = bankAccounts
  }

  public init(items: [VaultItem]) {
    credentials = items.compactMap({ $0 as? Credential })
    secureNotes = items.compactMap({ $0 as? SecureNote })
    creditCards = items.compactMap({ $0 as? CreditCard })
    bankAccounts = items.compactMap({ $0 as? BankAccount })
  }
}

extension ImportableItems {
  func deduplicate() -> ImportableItems {
    let credentials = credentials.deduplicate()
    let secureNotes = secureNotes.deduplicate()
    let creditCards = creditCards.deduplicate()
    let bankAccounts = bankAccounts.deduplicate()
    return ImportableItems(
      credentials: credentials,
      secureNotes: secureNotes,
      creditCards: creditCards,
      bankAccounts: bankAccounts)
  }
}

extension ApplicationDatabase {

  func filterExisting(items: ImportableItems) -> ImportableItems {
    let credentials = filterExisting(items: items.credentials)
    let secureNotes = filterExisting(items: items.secureNotes)
    let creditCards = filterExisting(items: items.creditCards)
    let bankAccounts = filterExisting(items: items.bankAccounts)
    return ImportableItems(
      credentials: credentials,
      secureNotes: secureNotes,
      creditCards: creditCards,
      bankAccounts: bankAccounts)
  }
}
