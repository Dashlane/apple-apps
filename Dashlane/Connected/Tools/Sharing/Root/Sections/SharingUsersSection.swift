import CorePersonalData
import CoreSharing
import IconLibrary
import SwiftUI
import UIComponents
import VaultKit

struct SharingUsersSection: View {
  @ObservedObject
  var model: SharingUsersSectionViewModel

  var body: some View {
    if let users = model.users, !users.isEmpty {
      Section(L10n.Localizable.kwSharingCenterSectionIndividuals) {
        ForEach(users) { user in
          NavigationLink {
            SharingItemsUserDetailView(model: model.makeDetailViewModel(user: user))
          } label: {
            SharingToolRecipientRow(title: user.id, itemsCount: user.items.count) {
              GravatarIconView(
                model: model.gravatarIconViewModelFactory.make(email: user.id), isLarge: false)
            }
          }

        }
      }
    }
  }
}

struct SharingUsersSection_Previews: PreviewProvider {
  static let itemsProvider = SharingToolItemsProvider.mock(vaultItemByIds: [
    "1": PersonalDataMock.Credentials.adobe,
    "2": PersonalDataMock.Credentials.amazon,
    "3": PersonalDataMock.Credentials.github,
  ])

  static let sharingService = SharingServiceMock(sharingUsers: [
    .init(id: "_", items: [.mock(id: "1")]),
    .init(id: "_", items: [.mock(id: "2"), .mock(id: "3")]),
  ])

  static let gravatarFactory: GravatarIconViewModel.SecondFactory = .init({ email in
    GravatarIconViewModel(email: email, iconLibrary: FakeGravatarIconLibrary(icon: nil))
  })

  static var previews: some View {
    NavigationView {
      List {
        SharingUsersSection(
          model: .init(
            itemsProvider: itemsProvider,
            sharingService: sharingService,
            detailViewModelFactory: .init {
              .mock(user: $0, item: Credential(), itemsProvider: $2)
            },
            gravatarIconViewModelFactory: gravatarFactory))

      }
      .listStyle(.ds.insetGrouped)
      .previewDisplayName("Two users")
    }

    List {
      SharingUsersSection(
        model: .init(
          itemsProvider: itemsProvider,
          sharingService: SharingServiceMock(),
          detailViewModelFactory: .init { .mock(user: $0, item: Credential(), itemsProvider: $2) },
          gravatarIconViewModelFactory: gravatarFactory))
    }
    .listStyle(.ds.insetGrouped)
    .previewDisplayName("Empty")

  }
}
