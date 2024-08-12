import DashTypes
import DashlaneAPI
import Foundation

extension SharingClientAPIImpl {
  public static let sliceSize = 100

  public func findPublicKeys(for userIds: [UserId]) async throws -> [UserId: RawPublicKey] {
    let userIdSlices = userIds.chunked(into: FetchRequest.sliceSize)
    return try await apiClient.getUsersPublicKey(logins: userIdSlices)
  }

  public func getTeamLogins() async throws -> [String] {
    return try await apiClient.getTeamLogins().teamLogins
  }
}

extension UserDeviceAPIClient.SharingUserdevice.GetUsersPublicKey {
  fileprivate func callAsFunction(logins: [[String]]) async throws -> [UserId: RawPublicKey] {
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
