import DashTypes
import DashlaneAPI
import Foundation

struct ActivityLogsUploader {

  let apiClient: UserDeviceAPIClient.Teams.StoreActivityLogs
  let logger: Logger

  typealias InvalidLogError = UserDeviceAPIClient.Teams.StoreActivityLogs.Response
    .InvalidActivityLogsElement.Error

  enum Error: Swift.Error {
    case invalidLogs(InvalidLogError)
    case couldNotUploadLogs(Swift.Error)
  }

  func upload(_ activityLog: ActivityLog) async throws {
    do {
      let response = try await apiClient(activityLogs: [activityLog])
      if let invalidLog = response.invalidActivityLogs.first {
        throw Error.invalidLogs(invalidLog.error)
      }
    } catch let Error.invalidLogs(invalidLog) {
      logger.error("Invalid audit log \(invalidLog.rawValue)")
    } catch {
      throw Error.couldNotUploadLogs(error)
    }

  }
}
