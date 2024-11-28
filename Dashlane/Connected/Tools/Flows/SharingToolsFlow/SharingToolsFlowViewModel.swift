import Combine
import CorePersonalData
import DashTypes
import Foundation
import SwiftUI
import VaultKit

@MainActor
class SharingToolsFlowViewModel: ObservableObject, SessionServicesInjecting {

  enum Step {
    case root
    case credentialDetails(VaultItem)
  }

  @Published
  var steps: [Step] = [.root]

  let accessControl: AccessControlHandler
  let detailViewModelFactory: VaultDetailViewModel.Factory
  let sharingToolViewModelFactory: SharingToolViewModel.Factory

  init(
    accessControl: AccessControlHandler,
    detailViewModelFactory: VaultDetailViewModel.Factory,
    sharingToolViewModelFactory: SharingToolViewModel.Factory
  ) {
    self.accessControl = accessControl
    self.detailViewModelFactory = detailViewModelFactory
    self.sharingToolViewModelFactory = sharingToolViewModelFactory
  }

  func makeShowVaultItemAction() -> ShowVaultItemAction {
    .init { [weak self] item in
      self?.showDetail(for: item)
    }
  }

  func showDetail(for item: VaultItem) {
    accessControl.requestAccess(to: item) { [weak self] success in
      guard success else {
        return
      }

      self?.steps.append(.credentialDetails(item))
    }
  }
}

extension SharingToolsFlowViewModel {
  func makeDetailViewModel() -> VaultDetailViewModel {
    detailViewModelFactory.make()
  }
}

extension SharingToolsFlowViewModel {
  static var mock: SharingToolsFlowViewModel {
    .init(
      accessControl: .mock(),
      detailViewModelFactory: .init({ .mock() }),
      sharingToolViewModelFactory: .init({
        .mock(
          itemsProvider: .mock(), userSpacesService: .mock(), sharingService: SharingServiceMock())
      }))
  }
}
