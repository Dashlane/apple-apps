import Foundation
extension UserDeviceAPIClient.Sync {
        public struct GetDataForMasterPasswordChange: APIRequest {
        public static let endpoint: Endpoint = "/sync/GetDataForMasterPasswordChange"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getDataForMasterPasswordChange: GetDataForMasterPasswordChange {
        GetDataForMasterPasswordChange(api: api)
    }
}

extension UserDeviceAPIClient.Sync.GetDataForMasterPasswordChange {
        public struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Sync.GetDataForMasterPasswordChange {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public enum OtpStatus: String, Codable, Equatable, CaseIterable {
            case disabled = "disabled"
            case newDevice = "newDevice"
            case login = "login"
        }

        private enum CodingKeys: String, CodingKey {
            case timestamp = "timestamp"
            case otpStatus = "otpStatus"
            case data = "data"
        }

                public let timestamp: Int

                public let otpStatus: OtpStatus

        public let data: DataType

                public struct DataType: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case transactions = "transactions"
                case sharingKeys = "sharingKeys"
            }

                        public let transactions: [Transactions]

            public let sharingKeys: SyncSharingKeys

                        public struct Transactions: Codable, Equatable {

                private enum CodingKeys: String, CodingKey {
                    case backupDate = "backupDate"
                    case identifier = "identifier"
                    case time = "time"
                    case content = "content"
                    case type = "type"
                    case action = "action"
                }

                                public let backupDate: Int

                                public let identifier: String

                                public let time: Int

                                public let content: String

                                public let type: String

                public let action: SyncDataAction

                public init(backupDate: Int, identifier: String, time: Int, content: String, type: String, action: SyncDataAction) {
                    self.backupDate = backupDate
                    self.identifier = identifier
                    self.time = time
                    self.content = content
                    self.type = type
                    self.action = action
                }
            }

            public init(transactions: [Transactions], sharingKeys: SyncSharingKeys) {
                self.transactions = transactions
                self.sharingKeys = sharingKeys
            }
        }

        public init(timestamp: Int, otpStatus: OtpStatus, data: DataType) {
            self.timestamp = timestamp
            self.otpStatus = otpStatus
            self.data = data
        }
    }
}
