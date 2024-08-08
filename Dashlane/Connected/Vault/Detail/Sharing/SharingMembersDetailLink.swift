import CoreSharing
import SwiftUI
import VaultKit

struct SharingMembersDetailLink: View {
  @StateObject
  var model: SharingMembersDetailLinkModel

  init(model: @autoclosure @escaping () -> SharingMembersDetailLinkModel) {
    _model = .init(wrappedValue: model())
  }

  var body: some View {
    if let itemMembers = model.itemMembers, let title = itemMembers.localizedTitle {
      NavigationLink(title) {
        SharingMembersDetailView(
          model: model.detailViewModelFactory.make(members: itemMembers, item: model.item))
      }
    }
  }
}

struct SharingMembersDetailLink_Previews: PreviewProvider {
  static let credential = PersonalDataMock.Credentials.sharedAdminPermissionCredential

  static var previews: some View {
    SharingMembersDetailLink(
      model: .mock(
        item: credential,
        sharingService: SharingServiceMock(
          itemSharingMember: .init(
            itemGroupInfo: .mock(),
            users: [.mock(), .mock()],
            userGroupMembers: [.mock(), .mock()],
            collectionMembers: [.mock(), .mock()]
          )
        )
      )
    ).previewDisplayName("Multiple Users & User Groups")

    SharingMembersDetailLink(
      model: .mock(
        item: credential,
        sharingService: SharingServiceMock(
          itemSharingMember: .init(
            itemGroupInfo: .mock(),
            users: [.mock()],
            userGroupMembers: [.mock()],
            collectionMembers: [.mock()]
          )
        )
      )
    ).previewDisplayName("One User & one user group")

    SharingMembersDetailLink(
      model: .mock(
        item: credential,
        sharingService: SharingServiceMock(
          itemSharingMember: .init(
            itemGroupInfo: .mock(),
            users: [],
            userGroupMembers: [.mock(), .mock()],
            collectionMembers: []
          )
        )
      )
    ).previewDisplayName("Only User Groups")

    SharingMembersDetailLink(
      model: .mock(
        item: credential,
        sharingService: SharingServiceMock(
          itemSharingMember: .init(
            itemGroupInfo: .mock(),
            users: [.mock(), .mock()],
            userGroupMembers: [],
            collectionMembers: []
          )
        )
      )
    ).previewDisplayName("Only users")
  }
}
