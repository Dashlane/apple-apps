import Foundation
import DashTypes
import CoreSharing
import CoreSession
import CorePersonalData
import Combine
import VaultKit
import DashlaneAppKit
import CorePremium

@MainActor
class SharingPendingItemGroupsSectionViewModel: ObservableObject, SessionServicesInjecting {
    let vaultItemRowModelFactory: VaultItemRowModel.Factory

    @Published
    var pendingItemGroups: [PendingDecodedItemGroup]?

    @Published
    var isSpaceSelectionRequired: Bool = false
    private var pendingSpaceSelectionContinuation: CheckedContinuation<UserSpace?, Never>? {
        didSet {
            isSpaceSelectionRequired = pendingSpaceSelectionContinuation != nil
        }
    }

    var availableSpaces: [UserSpace] {
        return teamSpacesService.availableSpaces.filter {
            $0 != .both
        }
    }

    private let sharingService: SharingServiceProtocol
    private let teamSpacesService: TeamSpacesService

    public init(sharingService: SharingServiceProtocol,
                teamSpacesService: TeamSpacesService,
                vaultItemRowModelFactory: VaultItemRowModel.Factory) {
        self.sharingService = sharingService
        self.teamSpacesService = teamSpacesService
        self.vaultItemRowModelFactory = vaultItemRowModelFactory

        sharingService.pendingItemGroupsPublisher()
            .combineLatest(sharingService.pendingItemsPublisher()) { pendingGroups, pendingItems -> [PendingDecodedItemGroup] in
                return pendingGroups.compactMap { pendingGroup -> PendingDecodedItemGroup? in
                                        guard let firstId = pendingGroup.itemIds.first, let item = pendingItems[firstId] else {
                        return nil
                    }

                    return PendingDecodedItemGroup(itemGroupInfo: pendingGroup.itemGroupInfo, item: item, referrer: pendingGroup.referrer)
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$pendingItemGroups)
    }

    func accept(_ group: PendingDecodedItemGroup) async throws {
        guard let businessTeam = teamSpacesService.availableBusinessTeam else {
            try await sharingService.accept(group, in: UserSpace.personal)
            return
        }

        if businessTeam.shouldBeForced(on: group.item) { 
            try await sharingService.accept(group, in: .business(businessTeam))
        } else if group.item.spaceId == businessTeam.teamId { 
            try await sharingService.accept(group)
        } else {
            let space = await withCheckedContinuation { continuation in
                self.pendingSpaceSelectionContinuation = continuation
            }
            guard let space = space else {
                return
            }

            try await sharingService.accept(group, in: space)
        }
    }

    func select(_ userSpace: UserSpace?) {
        pendingSpaceSelectionContinuation?.resume(returning: userSpace)
    }

    func refuse(_ group: PendingDecodedItemGroup) async throws {
        try await sharingService.refuse(group.itemGroupInfo, loggedItem: group.item)
    }
}

public struct PendingDecodedItemGroup: Identifiable {
    public let itemGroupInfo: ItemGroupInfo
    public let item: VaultItem
    public let referrer: String?

    public var id: Identifier {
        return itemGroupInfo.id
    }
}

extension SharingServiceProtocol {
    func accept(_ group: PendingDecodedItemGroup, in userSpace: UserSpace? = nil) async throws {
        if let personalDataId = userSpace?.personalDataId {
            update(spaceId: personalDataId, toPendingItem: group.item)
        }

        try await accept(group.itemGroupInfo, loggedItem: group.item)
    }
}
