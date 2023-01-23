import Foundation
import SwiftTreats
import DashTypes
import CyrilKit
import CorePersonalData
import CoreSharing
import CoreSession
import CoreSync
import CoreUserTracking
import DashlaneCrypto
import Combine
import DashlaneAPI

public class SharingService: SharingServiceProtocol {
        @Published
    var isReady: Bool = false

    private let userId: UserId
    let personalDataDB: SharingPersonalDataDBStack
    public let engine: SharingEngine<SQLiteDatabase>
    let activityReporter: SharingActivityReporter
    let keysStore: SharingKeysStore

    public init(session: Session,
                apiClient: UserDeviceAPIClient.SharingUserdevice,
                codeDecoder: CodeDecoder,
                personalDataURLDecoder: PersonalDataURLDecoder,
                databaseDriver: DatabaseDriver,
                sharingKeysStore: SharingKeysStore,
                logger: Logger,
                activityReporter: ActivityReporterProtocol) async throws {
        userId = session.login.email
        keysStore = sharingKeysStore
        personalDataDB = SharingPersonalDataDBStack(driver: databaseDriver,
                                                    codeDecoder: codeDecoder,
                                                    personalDataURLDecoder: personalDataURLDecoder,
                                                    historyUserInfo: HistoryUserInfo(session: session),
                                                    logger: logger)
        self.activityReporter = activityReporter.sharing

        let cryptoProvider = CyrilSharingCryptoProvider { key in
            SpecializedCryptoEngine(cryptoCenter:  CryptoCenter(configuration: .kwc5), secret: .key(key))
        } symmetricKeyProvider: {
            Random.randomData(ofSize: 32)
        }
           
        let folder = try session.directory.storeURL(for: .sharing, in: .app)
        let queue = AsyncDistributedSerialQueue(lockFile: folder.appendingPathExtension("lock"), maximumLockDuration: 10)
        let key = await sharingKeysStore.keyPair()
        let url = folder.appendingPathComponent("sharing2.db")
       
        engine = try await SharingEngine(url: url,
                                         userId: session.login.email,
                                         userKeys: key,
                                         serialExecutionQueue: queue,
                                         apiClient: apiClient,
                                         personalDataDB: personalDataDB,
                                         cryptoProvider: cryptoProvider,
                                         logger: logger)
    }
    
    public func isReadyPublisher() -> AnyPublisher<Bool, Never> {
        return $isReady.eraseToAnyPublisher()
    }
}

extension HistoryUserInfo {
    init(session: Session) {
        self.init(platform: System.systemName,
                  deviceName: Device.name,
                  user: session.login.email)
    }
}

public extension SharingService {
    func pendingUserGroupsPublisher() -> AnyPublisher<[PendingUserGroup], Never> {
        return engine.database.pendingUserGroups(for: userId).publisher().replaceError(with: []).eraseToAnyPublisher()
    }
    
    func pendingItemGroupsPublisher() -> AnyPublisher<[PendingItemGroup], Never> {
        return engine.database.pendingItemGroups(for: userId).publisher().replaceError(with: []).eraseToAnyPublisher()
    }
    
    func sharingUserGroupsPublisher() -> AnyPublisher<[SharingItemsUserGroup], Never> {
        return engine.database.sharingUserGroups(for: userId).publisher().replaceError(with: []).eraseToAnyPublisher()
    }

    func sharingUsersPublisher() -> AnyPublisher<[SharingItemsUser], Never> {
        return engine.database.sharingUsers(for: userId).publisher().replaceError(with: []).eraseToAnyPublisher()
    }
    
    func sharingMembers(forItemId id: Identifier) -> AnyPublisher<ItemSharingMembers?, Never> {
        return engine.database.sharingMembers(forItemId: id).publisher().replaceError(with: nil).eraseToAnyPublisher()
    }
}

public extension SharingService {
    func pendingItemsPublisher() -> AnyPublisher<[Identifier: VaultItem], Never> {
        return personalDataDB.pendingItemsPublisher().map { $0.compactMapValues { $0 as? VaultItem } }.eraseToAnyPublisher()
    }
    
    func update(spaceId: String, toPendingItem item: VaultItem) {
        personalDataDB.update(spaceId: spaceId, toPendingItemWithId: item.id)
    }
}

public extension SharingService {
    func accept(_ itemGroupInfo: ItemGroupInfo, loggedItem: VaultItem) async throws {
        do {
            try await engine.accept(itemGroupInfo)

            activityReporter.reportPendingItemGroupResponse(for: loggedItem, accepted: true, success: true)
        }  catch {
            activityReporter.reportPendingItemGroupResponse(for: loggedItem, accepted: true, success: false)
            throw error
        }
    }
    
    func refuse(_ itemGroupInfo: ItemGroupInfo, loggedItem: VaultItem) async throws {
        do {
            try await engine.refuse(itemGroupInfo)

            activityReporter.reportPendingItemGroupResponse(for: loggedItem, accepted: false, success: true)
        }  catch {
            activityReporter.reportPendingItemGroupResponse(for: loggedItem, accepted: false, success: false)
            throw error
        }
    }
    
    func accept(_ groupInfo: UserGroupInfo) async throws {
        try await engine.accept(groupInfo)
    }
    
    func refuse(_ groupInfo: UserGroupInfo) async throws {
        try await engine.refuse(groupInfo)
    }
    
    func revoke(in group: ItemGroupInfo,
                users: [User]?,
                userGroupMembers: [UserGroupMember]?,
                loggedItem: VaultItem) async throws {
        do {
            try await engine.revoke(in: group,
                                    users: users,
                                    userGroupMembers: userGroupMembers)

            activityReporter.reportRevoke(of: loggedItem, success: true)
        } catch {
            activityReporter.reportRevoke(of: loggedItem, success: false)
            throw error
        }
    }
    
    func updatePermission(_ permission: SharingPermission,
                          of user: User,
                          in group: ItemGroupInfo,
                          loggedItem: VaultItem) async throws {
        do {
            try await engine.updatePermission(permission,
                                              of: user,
                                              in: group)

            activityReporter.reportPermissionUpdate(of: loggedItem, to: permission, success: true)
        } catch {
            activityReporter.reportPermissionUpdate(of: loggedItem, to: permission, success: false)
            throw error
        }
    }
    
    func updatePermission(_ permission: SharingPermission,
                          of userGroupMember: UserGroupMember,
                          in group: ItemGroupInfo,
                          loggedItem: VaultItem)  async throws {
        do {
            try await engine.updatePermission(permission,
                                              of: userGroupMember,
                                              in: group)

            activityReporter.reportPermissionUpdate(of: loggedItem, to: permission, success: true)

        } catch {
            activityReporter.reportPermissionUpdate(of: loggedItem, to: permission, success: false)
            throw error
        }
    }

    func resendInvites(to users: [User], in group: ItemGroupInfo) async throws {
        try await engine.resendInvites(to: users, in: group)
    }

    func share(_ items: [VaultItem],
               recipients: [String],
               userGroupIds: [Identifier],
               permission: SharingPermission,
               limitPerUser: Int?) async throws {
        do {
            try await engine.shareItems(withIds: items.map(\.id),
                                        recipients: recipients,
                                        userGroupIds: userGroupIds,
                                        permission: permission,
                                        limitPerUser: limitPerUser)

            activityReporter.reportCreate(with: items, userRecipients: recipients, userGroupIds: userGroupIds, permission: permission, success: true)
        } catch {
            activityReporter.reportCreate(with: items, userRecipients: recipients, userGroupIds: userGroupIds, permission: permission, success: false)
            throw error
        }
    }
}
