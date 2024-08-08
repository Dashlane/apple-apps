import CoreActivityLogs

extension ActivityLogsServiceProtocol {

  func logSave(_ item: VaultItem) {
    guard isEnabled, let info = item.reportableInfo() else {
      return
    }
    try? report(item.isSaved ? .update : .creation, for: info)
  }

  func logSave(_ items: [VaultItem]) {
    guard isEnabled else { return }
    for item in items {
      guard let info = item.reportableInfo() else {
        return
      }
      try? report(item.isSaved ? .update : .creation, for: info)
    }
  }

  func logDelete(_ item: VaultItem) {
    guard isEnabled, let info = item.reportableInfo() else {
      return
    }
    try? report(.deletion, for: info)
  }
}
