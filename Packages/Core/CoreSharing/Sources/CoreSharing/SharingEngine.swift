import Foundation
import DashTypes
import CyrilKit
import SwiftTreats
import DashlaneAPI

public typealias UserKeyProvider = @SharingActor () throws -> AsymmetricKeyPair

public struct SharingEngine<UIDatabase: SharingUIDatabase> {
        public let database: UIDatabase
    let operationDatabase: SharingOperationsDatabase
    let personalDataDB: SharingPersonalDataDB
    let sharingClientAPI: SharingClientAPI
    let cryptoProvider: SharingCryptoProvider
    let logger: Logger
    let userId: UserId
    let userKeyStore: UserKeyStore
        private let serialExecutionQueue: AsyncQueue
    let groupKeyProvider: GroupKeyProvider
    let updater: SharingUpdater

    @SharingActor
    public var needsKey: Bool {
        return userKeyStore.needsKey
    }

    @SharingActor
    init(userId: UserId,
         serialExecutionQueue: AsyncQueue,
         database: UIDatabase,
         operationDatabase: SharingOperationsDatabase,
         sharingClientAPI: SharingClientAPI,
         personalDataDB: SharingPersonalDataDB,
         cryptoProvider: SharingCryptoProvider,
         autoRevokeUsersWithInvalidProposeSignature: Bool,
         logger: Logger) {
        self.userKeyStore = UserKeyStore()
        self.userId = userId
        self.serialExecutionQueue = serialExecutionQueue
        self.database = database
        self.operationDatabase = operationDatabase
        self.sharingClientAPI = sharingClientAPI
        self.personalDataDB = personalDataDB
        self.cryptoProvider = cryptoProvider
        self.logger = logger
        groupKeyProvider = GroupKeyProvider(userId: userId,
                                            userKeyProvider: userKeyStore.get,
                                            database: operationDatabase,
                                            cryptoProvider: cryptoProvider)

        updater = SharingUpdater(userId: userId,
                                 userKeyProvider: userKeyStore.get,
                                 groupKeyProvider: groupKeyProvider,
                                 sharingClientAPI: sharingClientAPI,
                                 database: operationDatabase,
                                 cryptoProvider: cryptoProvider,
                                 personalDataDB: personalDataDB,
                                 autoRevokeUsersWithInvalidProposeSignature: autoRevokeUsersWithInvalidProposeSignature,
                                 logger: logger)
    }

                    func execute(maxIteration: Int = 5, _ action: @escaping @SharingActor (_ nextRequest: inout SharingUpdater.UpdateRequest) async throws -> Void) async throws {
        try await serialExecutionQueue {
            try await updater.execute(maxIteration: maxIteration, action)
        }
    }

                public func update(from summary: SharingSummary) async throws {
        try await serialExecutionQueue {
            try await updater.update(from: summary)
        }
    }

        public func updateUserKey(_ userKey: AsymmetricKeyPair) async throws {
        try await serialExecutionQueue {
            await userKeyStore.update(userKey)
            try await updater.retrieveMissingItemsInPersonalData()
        }
    }
}

extension SharingEngine where UIDatabase == SQLiteDatabase {
    @SharingActor
    public init(url: URL,
                userId: UserId,
                userKeys: AsymmetricKeyPair?, 
                serialExecutionQueue: AsyncQueue,
                apiClient: UserDeviceAPIClient.SharingUserdevice,
                personalDataDB: SharingPersonalDataDB,
                cryptoProvider: SharingCryptoProvider,
                autoRevokeUsersWithInvalidProposeSignature: Bool,
                logger: Logger) async throws {
        let sqlDatabase = try SQLiteDatabase(url: url)
        self.init(userId: userId,
                  serialExecutionQueue: serialExecutionQueue,
                  database: sqlDatabase,
                  operationDatabase: sqlDatabase,
                  sharingClientAPI: SharingClientAPIImpl(apiClient: apiClient),
                  personalDataDB: personalDataDB,
                  cryptoProvider: cryptoProvider,
                  autoRevokeUsersWithInvalidProposeSignature: autoRevokeUsersWithInvalidProposeSignature,
                  logger: logger)

        if let keys = userKeys {
           try await self.updateUserKey(keys)
        }
    }
}

extension SharingUpdater {
                    func retrieveMissingItemsInPersonalData() async throws {
        let ids = try await personalDataDB.sharedItemIds()
        let contents = try database.fetchAllItemContentCaches(withoutIds: ids)
        let updateRequest = PersonalDataUpdateRequest(itemGroups: [], contents: contents)

        guard !contents.isEmpty else {
            return
        }

        try await updatePersonalDataItems(for: updateRequest, allItemGroups: try database.fetchAllItemGroups())
    }
}

public enum ItemDeleteBehaviour {
        case normal
        case canDeleteByLeavingItemGroup
        case cannotDeleteWhenNoOtherAdmin
        case cannotDeleteUserInvolvedInUserGroup
}
