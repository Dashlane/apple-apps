import Combine
import DashTypes

extension DetailService {

  func copy(_ value: String, fieldType: DetailFieldType) {
    updateLastLocalUseDate()
    pasteboardService.copy(value)
    self.eventPublisher.send(.copy(true))
    self.sendCopyUsageLog(fieldType: fieldType)
  }

  private func updateLastLocalUseDate() {
    vaultItemEditionService.updateLastLocalUseDate()
  }

  func showInVault() {
    deepLinkService.handle(.vault(.show(item, useEditMode: false, origin: .adding)))
  }
}
