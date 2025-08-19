import CorePersonalData
import Foundation
import VaultKit

public final class DetailServiceContextMenuAutofill<Item: VaultItem & Equatable> {

  public var item: Item
  public let vaultItemDatabase: VaultItemDatabaseProtocol
  private let pasteboardService: PasteboardServiceProtocol

  public init(
    item: Item,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    pasteboardService: PasteboardServiceProtocol
  ) {
    self.item = item
    self.vaultItemDatabase = vaultItemDatabase
    self.pasteboardService = pasteboardService
  }

  func copy(_ value: String) {
    pasteboardService.copy(value)
    updateLastLocalUseDate()
  }

  private func updateLastLocalUseDate() {
    vaultItemDatabase.updateLastUseDate(of: [item], origin: [.default])
  }

}
