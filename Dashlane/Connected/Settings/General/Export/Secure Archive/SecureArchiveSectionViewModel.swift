import CorePersonalData
import CorePremium
import Foundation
import VaultKit

@MainActor
class SecureArchiveSectionViewModel: ObservableObject, SessionServicesInjecting {

  @Published
  var exportStatus: ExportVaultStatus = .complete

  let vaultItemsStore: VaultItemsStore
  let exportSecureArchiveViewModelFactory: ExportSecureArchiveViewModel.Factory

  init(
    exportSecureArchiveViewModelFactory: ExportSecureArchiveViewModel.Factory,
    vaultItemsStore: VaultItemsStore,
    premiumStatusProvider: PremiumStatusProvider
  ) {
    self.exportSecureArchiveViewModelFactory = exportSecureArchiveViewModelFactory
    self.vaultItemsStore = vaultItemsStore
    premiumStatusProvider.statusPublisher
      .map(\.exportStatus)
      .receive(on: DispatchQueue.main)
      .assign(to: &$exportStatus)
  }

  func makeExportSecureArchiveViewModel() -> ExportSecureArchiveViewModel {
    assert(exportStatus != .disabled)
    return exportSecureArchiveViewModelFactory.make(
      onlyExportPersonalSpace: exportStatus == .limited)
  }
}

extension SecureArchiveSectionViewModel {
  static func mock(status: CorePremium.Status) -> SecureArchiveSectionViewModel {
    return SecureArchiveSectionViewModel(
      exportSecureArchiveViewModelFactory: .init({ _ in .mock }),
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      premiumStatusProvider: .mock(status: status))
  }
}
