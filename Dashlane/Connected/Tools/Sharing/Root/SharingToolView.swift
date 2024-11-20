import CorePremium
import CoreSharing
import DesignSystem
import IconLibrary
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

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
    .listAppearance(.insetGrouped)
  }

  private var loadingPlaceholder: some View {
    VStack(alignment: .center, spacing: 32) {
      Image(asset: FiberAsset.emptySharing)
      Text(L10n.Localizable.kwSharingDataLoading)
        .font(.body)
      ProgressView()
        .controlSize(.large)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      SharingPendingEntitiesSection(model: model.pendingEntitiesSectionViewModel)
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      SharingUserGroupsSection(model: model.userGroupsSectionViewModel)
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      SharingUsersSection(model: model.usersSectionViewModel)
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
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
      .accessibilityAddTraits(.isHeader)
  }

  private var leadingButton: UserSpaceSwitcher<EmptyView>? {
    if displaySpaceSwitchOnLeadingButton {
      return UserSpaceSwitcher(
        model: model.userSpaceSwitcherViewModelFactory.make(), displayTeamName: true)
    } else {
      return nil
    }
  }

  @ViewBuilder
  private var trailingButton: some View {
    if model.state == .ready || model.state == .empty {
      ShareButton(model: model.shareButtonViewModelFactory.make()) {
        Image(systemName: "plus.circle.fill")
      }
    }
  }
}

struct SharingToolView_Previews: PreviewProvider {
  static let itemsProvider = SharingToolItemsProvider.mock(vaultItemByIds: [
    "1": PersonalDataMock.SecureNotes.thinkDifferent,
    "2": PersonalDataMock.Credentials.sharedAdminPermissionCredential,
    "3": PersonalDataMock.Credentials.sharedLimitedPermissionCredential,
  ])

  static let sharingService = SharingServiceMock(
    pendingUserGroups: [.init(userGroupInfo: .mock(name: "A simple group"), referrer: "Michel")],
    pendingItemGroups: [
      PendingItemGroup(itemGroupInfo: .mock(), itemIds: ["0"], referrer: "Michel")
    ],
    sharingUserGroups: [
      .init(
        id: "group", name: "A simple group", isMember: true,
        items: [.mock(id: "1"), .mock(id: "2")], users: [.mock(), .mock(), .mock()])
    ],
    sharingUsers: [.init(id: "_", items: [.mock(id: "3")])],
    pendingItems: ["0": PersonalDataMock.Credentials.sharedAdminPermissionCredential])

  static let userSpacesService = UserSpacesService.mock()

  static var previews: some View {
    NavigationView {
      SharingToolView(
        model: .mock(
          itemsProvider: itemsProvider,
          userSpacesService: userSpacesService,
          sharingService: sharingService))
    }
    .previewDisplayName("Sharing Tool View")

    SharingToolView(
      model: .mock(
        itemsProvider: itemsProvider,
        userSpacesService: userSpacesService,
        sharingService: SharingServiceMock())
    )
    .previewDisplayName("Empty")

    SharingToolView(
      model: .mock(
        itemsProvider: itemsProvider,
        userSpacesService: userSpacesService,
        sharingService: SharingServiceMock(isReady: false))
    )
    .previewDisplayName("Loading")
  }

}
