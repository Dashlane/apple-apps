import Foundation
import DashTypes

extension GetLatestDataService {
    struct Keys {
        static let timestamp = "timestamp"
        static let transactions = "transactions"
        static let needsKeys = "needsKeys"
        static let teamAdminGroups = "teamAdminGroups"
    }
}

public struct GetLatestDataService {

        enum ErrorType: String, Error {
                case temporaryDisabled = "temporary_disabled"
        case other = ""
    }

    let apiClient: DeprecatedCustomAPIClient

    public init(apiClient: DeprecatedCustomAPIClient) {
        self.apiClient = apiClient
    }

                                public func latestData(fromTimestamp timestamp: Timestamp,
                           missingTransactions: [Identifier] = [],
                           needsKeys: Bool = false,
                           returnsTeamAdminGroups: Bool = false) async throws -> DownloadedTransactions {
        struct Params: Encodable {
            let timestamp: Timestamp
            let transactions: [Identifier]
            let needsKeys: Bool
            let teamAdminGroups: Bool
        }
        let params = Params(timestamp: timestamp,
                            transactions: missingTransactions,
                            needsKeys: needsKeys,
                            teamAdminGroups: returnsTeamAdminGroups)
        return try await apiClient.sendRequest(to: "v1/sync/GetLatestContent",
                                               using: HTTPMethod.post,
                                               input: params)
    }

    static func fetchAllDataForMasterPasswordChange(using apiClient: DeprecatedCustomAPIClient,
                                                    completion: @escaping (Result<AllDataForMasterPasswordChange, Error>) -> Void) {
        struct EmptyInput: Encodable {}

        apiClient.sendRequest(to: "v1/sync/GetDataForMasterPasswordChange",
                              using: .post,
                              input: EmptyInput(),
                              completion: completion)

    }
}

struct AllDataForMasterPasswordChange: Decodable {
    let timestamp: Timestamp
    let data: Content

    struct Content: Decodable {
        let sharingKeys: RawSharingKeys
        let transactions: [DownloadedTransaction]
    }
}
