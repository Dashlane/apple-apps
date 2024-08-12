import CorePremium
import CoreSharing
import DesignSystem
import SwiftUI
import UIComponents
import VaultKit

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
            Thumbnail.User.group
              .controlSize(.small)

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
    .init(userGroupInfo: .mock(name: "Very Long Name for a Group"), referrer: "A referrer"),
  ])

  static let userSpacesService: UserSpacesService = .mock()

  static var previews: some View {
    List {
      SharingPendingUserGroupsSection(
        model: .init(userSpacesService: userSpacesService, sharingService: sharingService))
    }
    .previewDisplayName("Two Pending Groups")
    .listStyle(.insetGrouped)

    List {
      SharingPendingUserGroupsSection(
        model: .init(
          userSpacesService: userSpacesService,
          sharingService: SharingServiceMock(pendingUserGroups: [])))
    }
    .previewDisplayName("Empty")
    .listStyle(.insetGrouped)
  }
}
