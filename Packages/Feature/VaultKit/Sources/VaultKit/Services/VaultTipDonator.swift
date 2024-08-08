struct VaultTipDonator {
  func donateCollectionCreation() {
    if #available(iOS 17, macOS 14, *) {
      Task {
        await VaultItemDragDropTip.collectionCreationEvent.donate()
      }
    }
  }
}
