import Foundation
import DashTypes
import DashlaneAPI

public extension SharingClientAPIImpl {
    static let sliceSize = 100

                func findPublicKeys(for userIds: [UserId]) async throws -> [UserId: RawPublicKey] {
        let userIdSlices = userIds.chunked(into: FetchRequest.sliceSize)
        return try await apiClient.getUsersPublicKey(logins: userIdSlices)
    }
}

fileprivate extension UserDeviceAPIClient.SharingUserdevice.GetUsersPublicKey {
    func callAsFunction(logins: [[String]]) async throws -> [UserId: RawPublicKey] {
        return try await withThrowingTaskGroup(of: Response.self) { group in

            for slice in logins {
                group.addTask {
                    return try await self.callAsFunction(logins: slice)
                }
            }

            var userPublicKeys: [UserId: RawPublicKey] = [:]
            for try await response in group {
                for data in response.data {
                    guard let key = data.publicKey, let login = data.login else {
                        continue
                    }

                    userPublicKeys[login] = key
                }
            }

            return userPublicKeys
        }
    }
}

struct ResponseParser<T: Codable>: ResponseParserProtocol {
    let decoder: JSONDecoder = .init()

    struct Response<T: Decodable>: Decodable {
        enum CodingKeys: CodingKey {
            case code
            case message
            case content
        }

        enum Code: Int, Decodable {
            case success = 200
            case invalid = 409
        }

        let content: T

        init(from decoder: Decoder) throws {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            let code = try keyedContainer.decode(Int.self, forKey: .code)

            switch Code(rawValue: code) {
            case .success:
                self.content = try keyedContainer.decode(T.self, forKey: .content)
            case .invalid:
                fallthrough
            default:
                let message = try? keyedContainer.decodeIfPresent(String.self, forKey: .message)
                throw LegacySharingError(code: code, message: message)
            }
        }
    }

    func parse(data: Data) throws -> T {
        return try decoder.decode(Response<T>.self, from: data).content
    }
}

public struct LegacySharingError: Error {
    public let code: Int
    public let message: String?
}
