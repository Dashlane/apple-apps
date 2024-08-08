import CorePremium
import Foundation

class SecureArchiveSectionContentViewModel: ObservableObject, SessionServicesInjecting {

  enum DashExportState {
    case limited
    case disabled
    case complete
  }

  let exportSecureArchiveViewModelFactory: ExportSecureArchiveViewModel.Factory

  @Published
  var exportFlowState: DashExportState = .complete

  init(
    exportSecureArchiveViewModelFactory: ExportSecureArchiveViewModel.Factory,
    premiumStatusProvider: PremiumStatusProvider
  ) {
    self.exportSecureArchiveViewModelFactory = exportSecureArchiveViewModelFactory

    premiumStatusProvider.statusPublisher.map { status in
      guard let team = status.b2bStatus?.currentTeam else {
        return .complete
      }

      if team.teamInfo.personalSpaceEnabled == false {
        return team.teamInfo.vaultExportEnabled == true ? .complete : .disabled
      } else if team.teamInfo.forcedDomainsEnabled == true {
        return .limited
      } else {
        return .complete
      }
    }.assign(to: &$exportFlowState)
  }

  static func mock(status: CorePremium.Status) -> SecureArchiveSectionContentViewModel {
    return SecureArchiveSectionContentViewModel(
      exportSecureArchiveViewModelFactory: .init({ _ in .mock }),
      premiumStatusProvider: .mock(status: status))
  }

}
