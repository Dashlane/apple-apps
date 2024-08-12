import CoreFeature
import CoreLocalization
import CorePremium
import CoreSharing
import DesignSystem
import SwiftUI
import UIComponents
import VaultKit

struct SharingPendingEntitiesSection: View {
  @ObservedObject
  var model: SharingPendingEntitiesSectionViewModel

  @Environment(\.toast)
  var toast

  var body: some View {
    if !model.pendingItemGroups.isEmpty || !model.pendingCollections.isEmpty {
      LargeHeaderSection(title: L10n.Localizable.kwSharingCenterSectionPendingItems) {
        ForEach(model.pendingItemGroups) { pendingGroup in
          PendingSharingRow { action in
            try await model.perform(action, on: pendingGroup)
          } label: {
            row(for: pendingGroup)
          }
        }.confirmationDialog(
          CoreLocalization.L10n.Core.teamSpacesSharingAcceptPrompt,
          isPresented: $model.isSpaceSelectionRequired, titleVisibility: .visible,
          actions: spacePickerDialog)

        ForEach(model.pendingCollections) { collection in
          PendingSharingRow { action in
            try await model.perform(action, on: collection, toast: toast)
          } label: {
            row(for: collection)
          }
        }
      }
      .toasterOn()

    }
  }

  @ViewBuilder
  func row(for pendingGroup: PendingDecodedItemGroup) -> some View {
    VaultItemRow(
      item: pendingGroup.item,
      userSpace: model.userSpacesService.configuration.displayedUserSpace(for: pendingGroup.item),
      vaultIconViewModelFactory: model.vaultItemIconViewModelFactory
    )
    .vaultItemRowHideSharing()
  }

  @ViewBuilder
  func row(for collection: PendingCollection) -> some View {
    SharingToolRecipientRow(title: collection.collectionInfo.name, subtitle: collection.referrer) {
      Image.ds.folder.outlined
    }
  }

  @ViewBuilder
  func spacePickerDialog() -> some View {
    ForEach(model.availableSpaces) { userSpace in
      Button(userSpace.teamName) {
        model.select(userSpace)
      }
    }

    Button(CoreLocalization.L10n.Core.cancel, role: .cancel) {
      model.select(nil)
    }
  }
}

extension SharingPendingEntitiesSectionViewModel {
  func perform(_ action: PendingSharingRowAction, on group: PendingDecodedItemGroup) async throws {
    switch action {
    case .accept:
      try await accept(group)
    case .refuse:
      try await refuse(group)
    }
  }

  func perform(
    _ action: PendingSharingRowAction, on collection: PendingCollection, toast: ToastAction
  ) async throws {
    switch action {
    case .accept:
      try await accept(collection, toast: toast)
    case .refuse:
      try await refuse(collection)
    }
  }
}

struct SharingPendingEntitiesSection_Previews: PreviewProvider {
  static let sharingService = SharingServiceMock(
    pendingItemGroups: [
      PendingItemGroup(itemGroupInfo: .mock(), itemIds: ["1"], referrer: "Michel"),
      PendingItemGroup(itemGroupInfo: .mock(), itemIds: ["2"], referrer: "Dominique"),
    ],
    pendingCollections: [
      PendingCollection(
        collectionInfo: CollectionInfo(
          id: .temporary, name: "Collec 1", publicKey: "aef", encryptedPrivateKey: "aef",
          revision: .zero), referrer: "Roger"),
      PendingCollection(
        collectionInfo: CollectionInfo(
          id: .temporary, name: "Collec 2", publicKey: "aef", encryptedPrivateKey: "aef",
          revision: .zero), referrer: "Donald"),
    ],
    pendingItems: [
      "1": PersonalDataMock.Credentials.wikipedia,
      "2": PersonalDataMock.SecureNotes.thinkDifferent,
    ]
  )

  static let userSpacesServiceOnlyPersonal: UserSpacesService = .mock(
    status: .Mock.premiumPlusWithAutoRenew)
  static let userSpacesServiceWithBusinessTeam: UserSpacesService = .mock(status: .Mock.team)

  static var previews: some View {
    List {
      SharingPendingEntitiesSection(
        model: .init(
          sharingService: sharingService,
          userSpacesService: userSpacesServiceOnlyPersonal,
          vaultItemIconViewModelFactory: .init { item in .mock(item: item) })
      )
    }
    .previewDisplayName("Two Pending Groups")
    .listStyle(.insetGrouped)

    List {
      SharingPendingEntitiesSection(
        model: .init(
          sharingService: sharingService,
          userSpacesService: userSpacesServiceWithBusinessTeam,
          vaultItemIconViewModelFactory: .init { item in .mock(item: item) })
      )
    }
    .previewDisplayName("Select Space Before Accept")
    .listStyle(.insetGrouped)

    List {
      SharingPendingEntitiesSection(
        model: .init(
          sharingService: SharingServiceMock(pendingUserGroups: []),
          userSpacesService: userSpacesServiceOnlyPersonal,
          vaultItemIconViewModelFactory: .init { item in .mock(item: item) })
      )
    }
    .previewDisplayName("Empty")
    .listStyle(.insetGrouped)
  }
}
