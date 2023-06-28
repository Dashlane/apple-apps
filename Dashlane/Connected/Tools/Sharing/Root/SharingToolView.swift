import SwiftUI
import SwiftTreats
import VaultKit
import CoreSharing
import IconLibrary
import UIComponents
import DesignSystem

struct SharingToolView: View {
    @StateObject
    var model: SharingToolViewModel

    init(model: @escaping @autoclosure () -> SharingToolViewModel) {
        self._model = .init(wrappedValue: model())
    }

    var body: some View {
        ZStack {
            switch model.state {
            case let .loading(serviceIsLoading):
                if serviceIsLoading {
                    loadingPlaceholder
                } else {
                    Color.ds.background.default
                }
            case .empty:
                emptyPlaceholder
            case .ready:
                list
            }
        }
        .toolbar { toolbarContent }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(displaySpaceSwitchOnLeadingButton)
        .reportPageAppearance(.sharingList)
        .animation(.easeInOut, value: model.state)
    }

    private var loadingPlaceholder: some View {
        VStack(alignment: .center, spacing: 32) {
            Image(asset: FiberAsset.emptySharing)
            Text(L10n.Localizable.kwSharingDataLoading)
                .font(.body)
            ProgressView()
                .controlSize(.large)
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 40)
    }

    private var emptyPlaceholder: some View {
        VStack(alignment: .center, spacing: 32) {
            SharingEmptyView()
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 40)
        .background(Color.ds.background.default)
    }

    private var list: some View {
        List {
            SharingPendingUserGroupsSection(model: model.pendingUserGroupsSectionViewModel)
            SharingPendingItemGroupsSection(model: model.pendingItemGroupsSectionViewModel)
            SharingUserGroupsSection(model: model.userGroupsSectionViewModel)
            SharingUsersSection(model: model.usersSectionViewModel)
        }
        .listStyle(.insetGrouped)
    }
}

extension SharingToolView {
    var displaySpaceSwitchOnLeadingButton: Bool {
        Device.isIpadOrMac
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            if displaySpaceSwitchOnLeadingButton {
                navigationBarTitleView
            } else {
                UserSpaceSwitcher(model: model.userSpaceSwitcherViewModelFactory.make()) {
                    navigationBarTitleView
                }
            }
        }
        ToolbarItem(placement: .navigationBarLeading) {
            leadingButton
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            trailingButton
        }
    }

    private var navigationBarTitleView: some View {
        Text(L10n.Localizable.tabContactsTitle)
            .foregroundColor(.ds.text.neutral.catchy)
            .font(.headline)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
    }

    private var leadingButton: UserSpaceSwitcher<EmptyView>? {
        if displaySpaceSwitchOnLeadingButton {
            return UserSpaceSwitcher(model: model.userSpaceSwitcherViewModelFactory.make(), displayTeamName: true)
        } else {
            return nil
        }
    }

    @ViewBuilder
    private var trailingButton: some View {
        if model.state == .ready || model.state == .empty {
            ShareButton(model: model.shareButtonViewModelFactory.make()) {
                Image(asset: FiberAsset.add)
            }
        }
    }
}

struct SharingToolView_Previews: PreviewProvider {
    static let itemsProvider = SharingToolItemsProvider.mock(vaultItemByIds: [
        "1": PersonalDataMock.SecureNotes.thinkDifferent,
        "2": PersonalDataMock.Credentials.sharedAdminPermissionCredential,
        "3": PersonalDataMock.Credentials.sharedLimitedPermissionCredential
    ])

    static let sharingService = SharingServiceMock(pendingUserGroups: [.init(userGroupInfo: .mock(name: "A simple group"), referrer: "Michel")],
                                                   pendingItemGroups: [PendingItemGroup(itemGroupInfo: .mock(), itemIds: ["0"], referrer: "Michel")],
                                                   sharingUserGroups: [SharingItemsUserGroup(id: "group", name: "A simple group", isMember: true, items: [.mock(id: "1"), .mock(id: "2")], users: [.mock(), .mock(), .mock()])
                                                                      ],
                                                   sharingUsers: [SharingItemsUser(id: "_", items: [.mock(id: "3")])],
                                                   pendingItems: ["0": PersonalDataMock.Credentials.sharedAdminPermissionCredential])

    static let teamSpacesService = TeamSpacesService.mock(selectedSpace: .both)

    static var previews: some View {
        NavigationView {
            SharingToolView(model: .mock(itemsProvider: itemsProvider,
                                         teamSpacesService: teamSpacesService,
                                         sharingService: sharingService))
        }
        .previewDisplayName("Sharing Tool View")

        SharingToolView(model: .mock(itemsProvider: itemsProvider,
                                     teamSpacesService: teamSpacesService,
                                     sharingService: SharingServiceMock()))
        .previewDisplayName("Empty")

        SharingToolView(model: .mock(itemsProvider: itemsProvider,
                                     teamSpacesService: teamSpacesService,
                                     sharingService: SharingServiceMock(isReady: false)))
        .previewDisplayName("Loading")
    }

 }
