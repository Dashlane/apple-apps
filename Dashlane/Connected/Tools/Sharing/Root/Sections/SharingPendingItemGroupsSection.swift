import SwiftUI
import VaultKit
import CoreSharing
import CorePremium
import UIComponents

struct SharingPendingItemGroupsSection: View {
    @ObservedObject
    var model: SharingPendingItemGroupsSectionViewModel

    var body: some View {
        if let groups = model.pendingItemGroups, !groups.isEmpty {
            LargeHeaderSection(title: L10n.Localizable.kwSharingCenterSectionPendingItems) {
                ForEach(groups) { pendingGroup in
                    PendingSharingRow { action in
                       try await model.perform(action, on: pendingGroup)
                    } label: {
                       row(for: pendingGroup)
                    }
                }.confirmationDialog(L10n.Localizable.teamSpacesSharingAcceptPrompt, isPresented: $model.isSpaceSelectionRequired, titleVisibility: .visible, actions: spacePickerDialog)
            }

        }
    }

    @ViewBuilder
    func row(for pendingGroup: PendingDecodedItemGroup) -> some View {
        VaultItemRow(model: model.vaultItemRowModelFactory.make(
            configuration: .init(item: pendingGroup.item, isSuggested: false),
            additionalConfiguration: .init(quickActionsEnabled: false, shouldShowSharingStatus: false, shouldShowSpace: false))
        )
    }

    @ViewBuilder
    func spacePickerDialog() -> some View {
        ForEach(model.availableSpaces) { userSpace in
            Button(userSpace.teamName) {
                model.select(userSpace)
            }
        }

        Button(L10n.Localizable.cancel, role: .cancel) {
            model.select(nil)
        }
    }
}

extension SharingPendingItemGroupsSectionViewModel {
    func perform(_ action: PendingSharingRowAction, on group: PendingDecodedItemGroup) async throws {

        switch action {
        case .accept:
            try await accept(group)
        case .refuse:
            try await refuse(group)
        }
    }
}

struct SharingPendingItemGroupsSection_Previews: PreviewProvider {
    static let sharingService =  SharingServiceMock(
        pendingItemGroups: [
            PendingItemGroup(itemGroupInfo: .mock(), itemIds: ["1"], referrer: "Michel"),
            PendingItemGroup(itemGroupInfo: .mock(), itemIds: ["2"], referrer: "Dominique")
        ],
        pendingItems: [
            "1": PersonalDataMock.Credentials.wikipedia,
            "2": PersonalDataMock.SecureNotes.thinkDifferent
        ]
    )

    static let businessTeam =  BusinessTeam(space: Space(teamId: "teamId",
                                                         teamName: "Dashlane",
                                                         letter: "D",
                                                         color: "d22",
                                                         associatedEmail: "",
                                                         membersNumber: 1,
                                                         teamAdmins: [],
                                                         billingAdmins: [],
                                                         isTeamAdmin: false,
                                                         isBillingAdmin: false,
                                                         planType: "",
                                                         status: .accepted,
                                                         info: SpaceInfo()),
                                            anonymousTeamId: "")

    static let teamSpacesServiceOnlyPersonal: TeamSpacesService = TeamSpacesService.mock()
    static let teamSpacesServiceWithBusinessTeam: TeamSpacesService = .mock(selectedSpace: .both, availableSpaces: [.personal, .business(businessTeam)], businessTeamsInfo: .init(businessTeams: [businessTeam]))

    static var previews: some View {
        List {
            SharingPendingItemGroupsSection(model: .init(
                sharingService: sharingService,
                teamSpacesService: teamSpacesServiceOnlyPersonal,
                vaultItemRowModelFactory: .init { .mock(configuration: $0, additionialConfiguration: $1) })
            )
        }
        .previewDisplayName("Two Pending Groups")
        .listStyle(.insetGrouped)

        List {
            SharingPendingItemGroupsSection(model: .init(
                sharingService: sharingService,
                teamSpacesService: teamSpacesServiceWithBusinessTeam,
                vaultItemRowModelFactory: .init { .mock(configuration: $0, additionialConfiguration: $1) })
            )
        }
        .previewDisplayName("Select Space Before Accept")
        .listStyle(.insetGrouped)

        List {
            SharingPendingItemGroupsSection(model: .init(
                sharingService: SharingServiceMock(pendingUserGroups: []),
                teamSpacesService: teamSpacesServiceOnlyPersonal,
                vaultItemRowModelFactory: .init { .mock(configuration: $0, additionialConfiguration: $1) })
            )
        }
        .previewDisplayName("Empty")
        .listStyle(.insetGrouped)
    }
 }
