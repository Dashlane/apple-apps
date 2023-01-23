import Foundation
import CoreSharing
import Combine
import SwiftUI
import VaultKit
import DashTypes
import CorePersonalData

@MainActor
class SharingMembersDetailLinkModel: ObservableObject, SessionServicesInjecting, MockVaultConnectedInjecting {
    @Published
    var itemMembers: ItemSharingMembers?
    let item: VaultItem
    let detailViewModelFactory: SharingMembersDetailViewModel.Factory
    init(item: VaultItem,
         sharingService: SharingServiceProtocol,
         detailViewModelFactory: SharingMembersDetailViewModel.Factory) {
        self.item = item
        self.detailViewModelFactory = detailViewModelFactory
        sharingService
            .sharingMembers(forItemId: item.id)
            .receive(on: DispatchQueue.main)
            .assign(to: &$itemMembers)
    }
}

extension SharingMembersDetailLinkModel {
    static func mock(item: VaultItem, sharingService: SharingServiceProtocol = SharingServiceMock()) -> SharingMembersDetailLinkModel {
        let detailFactory: SharingMembersDetailViewModel.Factory = .init { members, item in
            SharingMembersDetailViewModel(members: members,
                                          item: item,
                                          session: .mock,
                                          personalDataBD: ApplicationDBStack.mock(),
                                          gravatarViewModelFactory: .init { .mock(email: $0) },
                                          shareButtonModelFactory: .init { .mock(items: $0, userGroupIds: $1, userEmails: $2) },
                                          sharingService: sharingService)
        }

        return  SharingMembersDetailLinkModel(item: item,
                                              sharingService: SharingServiceMock(itemSharingMember: .init(itemGroupInfo: .mock(), users: [.mock(), .mock()], userGroupMembers: [.mock(), .mock()])),
                                              detailViewModelFactory: detailFactory)
    }
}
