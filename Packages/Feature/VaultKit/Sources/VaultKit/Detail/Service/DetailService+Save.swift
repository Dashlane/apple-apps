import Foundation
import Logger
import SwiftTreats

extension DetailService {

  @MainActor
  public func save() async {
    defer {
      isSaving = false
    }

    isSaving = true

    let itemDidChange = vaultItemEditionService.itemDidChange
    let collectionsDidChange = vaultCollectionEditionService.collectionsDidChange()

    guard mode.isAdding || itemDidChange || collectionsDidChange else {
      mode = .viewing
      return
    }
    do {
      try prepareForSaving()

      try vaultItemEditionService.save(
        with: selectedUserSpace,
        itemCollectionsCount: vaultCollectionEditionService.itemCollections.count
      )
      try await vaultCollectionEditionService.save()

      eventPublisher.send(.save)
    } catch {
      logger[.personalData].error("Error on save", error: error)
    }
  }

  public func saveIfViewing() {
    guard mode == .viewing else { return }
    Task {
      await save()
    }
  }
}
