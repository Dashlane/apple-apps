import Foundation
import DashTypes

public enum MigrationUploadMode: String {
    case masterKeyChange = "UploadDataForMasterPasswordChange"
    case cryptoConfigChange = "UploadDataForCryptoUpdate"
}

extension UploadContentService {
    struct Output: Decodable {
        let timestamp: Timestamp
    }
    
        static func upload(using mode: MigrationUploadMode,
                       content: DataForMasterPasswordChange,
                       authenticatedAPIClient apiClient: DeprecatedCustomAPIClient,
                       completion: @escaping (Result<Timestamp, Swift.Error>) -> Void) {
        apiClient.sendRequest(to: "v1/sync/\(mode.rawValue)",
                              using: HTTPMethod.post,
                              input: content) { (result: Result<Output, Swift.Error>) -> Void in
            switch result {
            case let .failure(error as APIErrorResponse):
                let code = error.errors.first?.code
                let uploadError = code.flatMap(Error.init)
                completion(.failure(uploadError ?? error))
            default:
                completion(result.map { $0.timestamp })
            }
            
        }
    }
}
