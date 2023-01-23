import Foundation
extension UserDeviceAPIClient.Sync {
        public struct UploadDataForMasterPasswordChange {
        public static let endpoint: Endpoint = "/sync/UploadDataForMasterPasswordChange"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timestamp: Int, transactions: [SyncUploadDataTransactions], sharingKeys: SyncSharingKeys, authTicket: String? = nil, remoteKeys: [SyncUploadDataRemoteKeys]? = nil, updateVerification: UpdateVerification? = nil, uploadReason: UploadReason? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(timestamp: timestamp, transactions: transactions, sharingKeys: sharingKeys, authTicket: authTicket, remoteKeys: remoteKeys, updateVerification: updateVerification, uploadReason: uploadReason)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var uploadDataForMasterPasswordChange: UploadDataForMasterPasswordChange {
        UploadDataForMasterPasswordChange(api: api)
    }
}

extension UserDeviceAPIClient.Sync.UploadDataForMasterPasswordChange {
        struct Body: Encodable {

                public let timestamp: Int

                public let transactions: [SyncUploadDataTransactions]

        public let sharingKeys: SyncSharingKeys

                public let authTicket: String?

                public let remoteKeys: [SyncUploadDataRemoteKeys]?

        public let updateVerification: UpdateVerification?

                public let uploadReason: UploadReason?
    }

        public enum UploadReason: String, Codable, Equatable, CaseIterable {
        case completeAccountRecovery = "complete_account_recovery"
        case masterPasswordMobileReset = "master_password_mobile_reset"
    }

        public struct UpdateVerification: Codable, Equatable {

                public enum `Type`: String, Codable, Equatable, CaseIterable {
            case emailToken = "email_token"
            case sso = "sso"
            case totpDeviceRegistration = "totp_device_registration"
            case totpLogin = "totp_login"
        }

                public let type: `Type`

                public let serverKey: String?

                public let ssoServerKey: String?

        public init(type: `Type`, serverKey: String? = nil, ssoServerKey: String? = nil) {
            self.type = type
            self.serverKey = serverKey
            self.ssoServerKey = ssoServerKey
        }
    }
}

extension UserDeviceAPIClient.Sync.UploadDataForMasterPasswordChange {
    public typealias Response = SyncUploadDataResponse
}
