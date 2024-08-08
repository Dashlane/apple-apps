import CSVParser
import CorePersonalData
import Foundation
import TOTPGenerator
import VaultKit

enum LastpassImportableItem {
  case credential(Credential)
  case secureNote(SecureNote)
  case bankAccount(BankAccount)
  case creditCard(CreditCard)

  var vaultItem: VaultItem {
    switch self {
    case let .credential(item):
      return item
    case let .secureNote(item):
      return item
    case let .bankAccount(item):
      return item
    case let .creditCard(item):
      return item
    }
  }

  init(from lastpassItem: LastpassItem, urlDecoder: PersonalDataURLDecoderProtocol) {
    if lastpassItem.hasSecureNotePrefix {
      switch LastpassNoteParser.parse(item: lastpassItem) {
      case let .bankAccount(bankAccount):
        self = .bankAccount(bankAccount)
      case let .creditCard(creditCard):
        self = .creditCard(creditCard)
      case nil:
        self = .secureNote(.init(from: lastpassItem))
      }
    } else {
      self = .credential(.init(from: lastpassItem, using: urlDecoder))
    }
  }
}

extension LastpassItem {
  fileprivate var hasSecureNotePrefix: Bool {
    url.hasPrefix(LastpassHeader.secureNotePrefix)
  }
}

extension LastpassItem {
  func makeVaultItem(using urlDecoder: PersonalDataURLDecoderProtocol) -> VaultItem? {
    LastpassImportableItem(from: self, urlDecoder: urlDecoder).vaultItem
  }
}

extension SecureNote {
  fileprivate init(from lastpassItem: LastpassItem) {
    self.init(
      title: lastpassItem.name,
      content: lastpassItem.extra)
  }
}

extension Credential {
  fileprivate init(
    from lastpassItem: LastpassItem, using urlDecoder: PersonalDataURLDecoderProtocol
  ) {
    self.init(
      login: lastpassItem.username,
      title: lastpassItem.name,
      password: lastpassItem.password,
      email: lastpassItem.username,
      otpURL: nil,
      url: lastpassItem.url,
      note: lastpassItem.extra
    )
    if let raw = url?.rawValue, let decoded = try? urlDecoder.decodeURL(raw) {
      url = decoded
    }
  }
}
