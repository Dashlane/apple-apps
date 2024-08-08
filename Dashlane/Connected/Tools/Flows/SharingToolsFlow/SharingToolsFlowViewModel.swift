import Combine
import CorePersonalData
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

  let accessControl: AccessControlProtocol
  let detailViewModelFactory: VaultDetailViewModel.Factory
  let sharingToolViewModelFactory: SharingToolViewModel.Factory
  var cancellables = Set<AnyCancellable>()

  init(
    accessControl: AccessControlProtocol,
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
    if let secureItem = item as? SecureItem, secureItem.secured {
      accessControl.requestAccess().sink { [weak self] success in
        if success {
          self?.steps.append(.credentialDetails(item))
        }
      }.store(in: &cancellables)
    } else {
      self.steps.append(.credentialDetails(item))
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
      accessControl: FakeAccessControl(accept: true),
      detailViewModelFactory: .init({ .mock() }),
      sharingToolViewModelFactory: .init({
        .mock(
          itemsProvider: .mock(), userSpacesService: .mock(), sharingService: SharingServiceMock())
      }))
  }
}
