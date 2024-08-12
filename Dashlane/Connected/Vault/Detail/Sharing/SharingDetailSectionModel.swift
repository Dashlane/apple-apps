import Combine
import Foundation
import VaultKit

@MainActor
struct SharingDetailSectionModel: SessionServicesInjecting, MockVaultConnectedInjecting {
  let item: VaultItem
  private let sharingMembersDetailLinkModelFactory: SharingMembersDetailLinkModel.Factory
  private let shareButtonModelFactory: ShareButtonViewModel.Factory

  public init(
    item: VaultItem,
    sharingMembersDetailLinkModelFactory: SharingMembersDetailLinkModel.Factory,
    shareButtonModelFactory: ShareButtonViewModel.Factory
  ) {
    self.item = item
    self.sharingMembersDetailLinkModelFactory = sharingMembersDetailLinkModelFactory
    self.shareButtonModelFactory = shareButtonModelFactory
  }

  func makeShareButtonViewModel() -> ShareButtonViewModel {
    return shareButtonModelFactory.make(items: [item])
  }

  func makeSharingMembersDetailLinkModel() -> SharingMembersDetailLinkModel {
    return sharingMembersDetailLinkModelFactory.make(item: item)
  }
}

extension SharingDetailSectionModel {
  static func mock(item: VaultItem) -> SharingDetailSectionModel {
    SharingDetailSectionModel(
      item: item,
      sharingMembersDetailLinkModelFactory: .init { .mock(item: $0) },
      shareButtonModelFactory: .init { .mock(items: $0, userGroupIds: $1, userEmails: $2) })
  }
}
