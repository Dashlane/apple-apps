import CoreSession
import CoreSharing
import DashTypes
import Foundation
import VaultKit

@MainActor
public class SharingCollectionMembersDetailViewModel: ObservableObject, SessionServicesInjecting {

  enum MembersAction {
    case revoke
    case changePermission(SharingPermission)
  }

  @Published
  var members: CollectionSharingMembers?

  @Published
  var search: String = ""

  @Published
  var isLoading: Bool = false

  @Published
  var alertMessage: String?

  @Published
  var groupActionInProgressIds: Set<Identifier> = []

  @Published
  var userActionInProgressIds: Set<UserId> = []

  var accessChanged: Bool = false

  @Published
  var actionToProcess: [(memberId: String, action: MembersAction)] = []

  let currentUserId: UserId

  let gravatarViewModelFactory: GravatarIconViewModel.SecondFactory

  private let sharingService: SharingServiceProtocol
  private let computingQueue = DispatchQueue(
    label: "com.dashlane.collection-members", qos: .userInitiated)

  init(
    collection: VaultCollection,
    session: Session,
    sharingService: SharingServiceProtocol,
    gravatarViewModelFactory: GravatarIconViewModel.SecondFactory
  ) {
    self.currentUserId = session.login.email
    self.sharingService = sharingService
    self.gravatarViewModelFactory = gravatarViewModelFactory

    configurePublishers(for: collection)
  }

  private func configurePublishers(for collection: VaultCollection) {
    let searchPublisher = $search.dropFirst().debounce(
      for: .seconds(0.3), scheduler: DispatchQueue.main
    )
    .map { $0.lowercased() }
    .prepend("")
    .receive(on: computingQueue)
    .shareReplayLatest()

    let membersPublisher = sharingService.sharingMembers(forCollectionId: collection.id)
      .compactMap { $0 }
      .receive(on: computingQueue)

    searchPublisher.combineLatest(membersPublisher) { search, members in
      let filteredUsers = members.users.filter(using: search)
      let filteredUserGroups = members.userGroupMembers.filter(using: search)
      return CollectionSharingMembers(
        collectionInfo: members.collectionInfo,
        users: filteredUsers,
        userGroupMembers: filteredUserGroups
      )
    }
    .receive(on: DispatchQueue.main)
    .assign(to: &$members)
  }
}

extension SharingCollectionMembersDetailViewModel {
  func update() async {
    isLoading = true

    var userGroupsToRevoke: [UserGroupMember<SharingCollection>] = []
    var usersToRevoke: [User<SharingCollection>] = []

    var userGroupsPermissionUpdate: [(UserGroupMember<SharingCollection>, SharingPermission)] = []
    var usersPermissionUpdate: [(User<SharingCollection>, SharingPermission)] = []

    for (identifier, action) in actionToProcess {
      if let user = members?.users.first(where: { $0.id == identifier }) {
        switch action {
        case .revoke:
          usersToRevoke.append(user)
        case .changePermission(let permission):
          usersPermissionUpdate.append((user, permission))
        }
      } else if let userGroup = members?.userGroupMembers.first(where: {
        $0.id.rawValue == identifier
      }) {
        switch action {
        case .revoke:
          userGroupsToRevoke.append(userGroup)
        case .changePermission(let permission):
          userGroupsPermissionUpdate.append((userGroup, permission))
        }
      } else {
        assertionFailure()
      }
    }

    do {
      try await revoke(usersToRevoke)
      try await revoke(userGroupsToRevoke)
      try await userGroupsPermissionUpdate.asyncForEach {
        try await updatePermission($0.1, of: $0.0)
      }
      try await usersPermissionUpdate.asyncForEach { try await updatePermission($0.1, of: $0.0) }
    } catch {
      alertMessage = L10n.Localizable.kwSharingCenterUnknownErrorAlertMessage
    }

    isLoading = false
  }
}

extension SharingCollectionMembersDetailViewModel {
  private func trackUserGroupActionProgress(
    on userGroup: UserGroupMember<some SharingGroup>, _ action: @escaping () async -> Void
  ) {
    Task {
      groupActionInProgressIds.insert(userGroup.id)
      await action()
      groupActionInProgressIds.remove(userGroup.id)
    }
  }

  func revoke(_ userGroup: UserGroupMember<SharingCollection>) {
    guard let collection = members?.collectionInfo else { return }
    trackUserGroupActionProgress(on: userGroup) {
      do {
        try await self.sharingService.revoke(
          in: collection,
          users: nil,
          userGroupMembers: [userGroup]
        )
        self.accessChanged = true
      } catch {
        self.alertMessage = L10n.Localizable.kwSharingCenterUnknownErrorAlertMessage
      }
    }
  }
}

extension SharingCollectionMembersDetailViewModel {
  private func trackUserActionProgress(
    on user: User<some SharingGroup>, _ action: @escaping () async -> Void
  ) {
    Task {
      userActionInProgressIds.insert(user.id)
      await action()
      userActionInProgressIds.remove(user.id)
    }
  }

  func revoke(_ user: User<SharingCollection>) {
    guard let collection = members?.collectionInfo else { return }
    trackUserActionProgress(on: user) {
      do {
        try await self.sharingService.revoke(
          in: collection,
          users: [user],
          userGroupMembers: nil
        )
        self.accessChanged = true
      } catch {
        self.alertMessage = L10n.Localizable.kwSharingCenterUnknownErrorAlertMessage
      }
    }
  }
}

extension SharingCollectionMembersDetailViewModel {
  fileprivate func revoke(_ userGroups: [UserGroupMember<SharingCollection>]) async throws {
    guard let collection = members?.collectionInfo else { return }
    try await sharingService.revoke(
      in: collection,
      users: nil,
      userGroupMembers: userGroups
    )
  }

  fileprivate func revoke(_ users: [User<SharingCollection>]) async throws {
    guard let collection = members?.collectionInfo else { return }
    try await sharingService.revoke(
      in: collection,
      users: users,
      userGroupMembers: nil
    )
  }

  fileprivate func updatePermission(
    _ permission: SharingPermission,
    of userGroup: UserGroupMember<SharingCollection>
  ) async throws {
    guard let collection = members?.collectionInfo else { return }
    try await sharingService.updatePermission(
      permission,
      of: userGroup,
      in: collection
    )
  }

  fileprivate func updatePermission(
    _ permission: SharingPermission,
    of user: User<SharingCollection>
  ) async throws {
    guard let collection = members?.collectionInfo else { return }
    try await sharingService.updatePermission(
      permission,
      of: user,
      in: collection
    )
  }
}

extension CollectionSharingMembers {
  fileprivate func filter(using search: String) -> CollectionSharingMembers {
    return .init(
      collectionInfo: collectionInfo,
      users: users.filter(using: search),
      userGroupMembers: userGroupMembers.filter(using: search)
    )
  }
}

private protocol SearchableGroupMember {
  var name: String { get }
}

extension Array where Element: SearchableGroupMember {
  fileprivate func filter(using search: String) -> Self {
    if search.isEmpty {
      return self
    } else {
      return self.filter { $0.name.lowercased().contains(search) }
    }
  }
}

extension UserGroupMember<SharingCollection>: SearchableGroupMember {}
extension User<SharingCollection>: SearchableGroupMember {
  var name: String { id }
}

extension SharingCollectionMembersDetailViewModel {
  public static func mock(collection: VaultCollection) -> SharingCollectionMembersDetailViewModel {
    .init(
      collection: collection,
      session: Session.mock,
      sharingService: SharingServiceMock(),
      gravatarViewModelFactory: .init { _ in .mock(email: "_") }
    )
  }
}
