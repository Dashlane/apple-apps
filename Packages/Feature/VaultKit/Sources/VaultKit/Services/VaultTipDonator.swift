struct VaultTipDonator {
  func donateCollectionCreation() {
    Task {
      await VaultItemDragDropTip.collectionCreationEvent.donate()
    }
  }
}
