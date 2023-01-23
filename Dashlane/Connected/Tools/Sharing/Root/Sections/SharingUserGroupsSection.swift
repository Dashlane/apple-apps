import SwiftUI
import VaultKit
import CoreSharing
import UIComponents

struct SharingUserGroupsSection: View {
    @ObservedObject
    var model: SharingUserGroupsSectionViewModel

    var body: some View {
        if let groups = model.userGroups, !groups.isEmpty {
            LargeHeaderSection(title: L10n.Localizable.kwSharingCenterSectionGroups) {
                ForEach(groups) { group in
                    NavigationLink {
                        SharingItemsUserGroupDetailView(model: model.makeDetailViewModel(userGroup: group))
                    } label: {
                        SharingToolRecipientRow(title: group.name, itemsCount: group.items.count) {
                            UserGroupIcon()
                        }
                    }
                }
            }
        }
    }
}

struct SharingUserGroupsSection_Previews: PreviewProvider {
    static let itemsProvider = SharingToolItemsProvider.mock(vaultItemByIds: [
        "1": PersonalDataMock.Credentials.adobe,
        "2": PersonalDataMock.Credentials.amazon,
        "3": PersonalDataMock.Credentials.github
    ])

    static let sharingService = SharingServiceMock(sharingUserGroups: [
        SharingItemsUserGroup(id: "group1", name: "A simple group", isMember: true, items: [.mock(id: "1")], users: [.mock(), .mock(), .mock()]),
        SharingItemsUserGroup(id: "group2", name: "Very Long Name for a Group", isMember: false, items: [.mock(id: "2"), .mock(id: "3")], users: [.mock()])
    ])

    static let detailViewModelFactory: SharingItemsUserGroupDetailViewModel.Factory = .init { .mock(userGroup: $0, itemsProvider: $2) }

    static var previews: some View {
        NavigationView {
            List {
                SharingUserGroupsSection(model: .init(itemsProvider: itemsProvider, detailViewModelFactory: detailViewModelFactory, sharingService: sharingService))
            }
        }
        .listStyle(.insetGrouped)
        .previewDisplayName("Two accepted groups")

        List {
            SharingUserGroupsSection(model: .init(itemsProvider: itemsProvider, detailViewModelFactory: detailViewModelFactory, sharingService: SharingServiceMock()))
        }
        .listStyle(.insetGrouped)
        .previewDisplayName("Empty")
    }
}
