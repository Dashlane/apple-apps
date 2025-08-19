import CoreLocalization
import CorePremium
import CoreSharing
import DesignSystem
import SwiftTreats
import SwiftUI
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
          loadingPlaceholderView
        } else {
          Color.ds.background.default
        }
      case let .empty(isVaultEmpty):
        emptyView(isVaultEmpty: isVaultEmpty)
      case .ready:
        sharingListView
      }
    }
    .toolbar { toolbarContent }
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(displaySpaceSwitchOnLeadingButton)
    .reportPageAppearance(.sharingList)
    .animation(.easeInOut, value: model.state)
    .listStyle(.ds.insetGrouped)
    .headerProminence(.increased)
  }

  private var loadingPlaceholderView: some View {
    VStack(alignment: .center, spacing: 24) {
      Text(L10n.Localizable.kwSharingDataLoading)
        .textStyle(.title.section.large)
        .foregroundStyle(Color.ds.text.neutral.catchy)

      ProgressView()
        .progressViewStyle(.indeterminate)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var sharingListView: some View {
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
  }

  private func emptyView(isVaultEmpty: Bool) -> some View {
    ToolIntroView(
      icon: ExpressiveIcon(.ds.shared.outlined),
      title: CoreL10n.SharingIntro.title
    ) {
      FeatureCard {
        FeatureRow(
          asset: ExpressiveIcon(.ds.action.share.outlined),
          title: CoreL10n.SharingIntro.subtitle1,
          description: CoreL10n.SharingIntro.description1
        )
      }

      if isVaultEmpty {
        Button {
          model.addPassword()
        } label: {
          Label(
            CoreL10n.SharingIntro.Cta.v1,
            icon: .ds.arrowRight.outlined
          )
        }
        .buttonStyle(.designSystem(.iconTrailing(.sizeToFit)))
      } else {
        ShareButton(model: model.shareButtonViewModelFactory.make()) {
          Text(CoreL10n.SharingIntro.Cta.v2)
        }
        .buttonStyle(.designSystem(.titleOnly(.sizeToFit)))
      }
    }
  }
}

extension SharingToolView {
  var displaySpaceSwitchOnLeadingButton: Bool {
    Device.is(.pad, .mac, .vision)
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
      .foregroundStyle(Color.ds.text.neutral.catchy)
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
    if model.state == .ready || model.state == .empty(isVaultEmpty: false) {
      ShareButton(model: model.shareButtonViewModelFactory.make()) {
        Image(systemName: "plus.circle.fill")
          .foregroundStyle(Color.ds.text.brand.quiet)
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
