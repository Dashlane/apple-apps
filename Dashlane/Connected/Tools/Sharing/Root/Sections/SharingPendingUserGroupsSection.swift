import SwiftUI
import UIComponents
import VaultKit
import CoreSharing

struct SharingPendingUserGroupsSection: View {
    @ObservedObject
    var model: SharingPendingUserGroupsSectionViewModel

    var body: some View {
        if let groups = model.pendingUserGroups, !groups.isEmpty {
            LargeHeaderSection(title: L10n.Localizable.kwSharingCenterSectionPendingUserGroups) {
                ForEach(groups) { userGroup in
                    PendingSharingRow { action in
                        try await model.perform(action, on: userGroup)
                    } label: {
                        UserGroupIcon()
                            .contactsIconStyle(isLarge: false)

                        Text(userGroup.userGroupInfo.name)
                            .font(.body)
                            .lineLimit(1)
                            .foregroundColor(.ds.text.neutral.catchy)
                    }
                }
            }
        }
    }
}

extension SharingPendingUserGroupsSectionViewModel {
    func perform(_ action: PendingSharingRowAction, on group: PendingUserGroup) async throws {
        switch action {
        case .accept:
            try await accept(group)
        case .refuse:
            try await refuse(group)
        }
    }
}

struct SharingPendingUserGroupsSection_Previews: PreviewProvider {
    static let sharingService = SharingServiceMock(pendingUserGroups: [
        .init(userGroupInfo: .mock(name: "A simple group"), referrer: "A referrer"),
        .init(userGroupInfo: .mock(name: "Very Long Name for a Group"), referrer: "A referrer")
    ])

    static let teamSpacesService = TeamSpacesService.mock(selectedSpace: .both)

    static var previews: some View {
        List {
            SharingPendingUserGroupsSection(model: .init(teamSpacesService: teamSpacesService, sharingService: sharingService))
        }
        .previewDisplayName("Two Pending Groups")
        .listStyle(.insetGrouped)

        List {
            SharingPendingUserGroupsSection(model: .init(teamSpacesService: teamSpacesService,
                                                         sharingService: SharingServiceMock(pendingUserGroups: [])))
        }
        .previewDisplayName("Empty")
        .listStyle(.insetGrouped)
    }
 }
