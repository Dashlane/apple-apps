import CorePersonalData
import CorePremium
import SwiftUI
import VaultKit

@MainActor
final class ExportCSVSettingsSectionModel: ObservableObject, SessionServicesInjecting {

  @Published var exportStatus: ExportVaultStatus = .complete

  private let vaultItemsStore: VaultItemsStore

  init(vaultItemsStore: VaultItemsStore, premiumStatusProvider: PremiumStatusProvider) {
    self.vaultItemsStore = vaultItemsStore
    premiumStatusProvider.statusPublisher
      .map(\.exportStatus)
      .receive(on: DispatchQueue.main)
      .assign(to: &$exportStatus)

  }

  func csv() -> DashlaneCSVExport {
    assert(exportStatus != .disabled)
    return vaultItemsStore.makeCSVExport(onlyExportPersonalSpace: exportStatus == .limited)
  }
}

extension ExportCSVSettingsSectionModel {
  static func mock(status: CorePremium.Status) -> ExportCSVSettingsSectionModel {
    .init(
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      premiumStatusProvider: .mock(status: status))
  }
}
