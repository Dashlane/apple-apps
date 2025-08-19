import Combine
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation

public protocol TeamAuditLogsServiceProtocol {

  var isEnabled: Bool { get }

  func auditLogDetails(for logs: @autoclosure () -> [Identifier: TeamVaultAuditLog]) async throws
    -> [Identifier: AuditLogDetails]

  func report(_ generateReportableInfo: @autoclosure () -> ReportableInfo?) throws
}

public struct TeamAuditLogsService: TeamAuditLogsServiceProtocol {
  typealias AuditLogDetailEncryptRequest = UserSecureNitroEncryptionAPIClient.Logs
    .EncryptAuditLogDetailsBatchWithTeamKey.Body.DetailsToEncryptBatchElement
  typealias AuditLogDetailEncryptData = AuditLogDetailEncryptRequest.DetailsToEncryptElement
  public enum EncryptionAuditLogsError: Error {
    case missingData(UUID)
    case maxRetryReached
  }

  public var isEnabled: Bool {
    return spaceIdWithActivtyLogsEnabled != nil
  }

  private let spaceIdWithActivtyLogsEnabled: String?
  private let reportService: AuditLogsReportService
  private let logsAPIClient: UserSecureNitroEncryptionAPIClient.Logs
  private let logger: Logger

  public init(
    space: SpaceInformation?,
    logsAPIClient: UserSecureNitroEncryptionAPIClient.Logs,
    cryptoEngine: CryptoEngine,
    storeURL: URL,
    logger: Logger
  ) {

    if let space, space.collectSensitiveDataAuditLogsEnabled {
      spaceIdWithActivtyLogsEnabled = space.id
    } else {
      spaceIdWithActivtyLogsEnabled = nil
    }

    self.logger = logger
    self.logsAPIClient = logsAPIClient
    self.reportService = AuditLogsReportService(
      logsAPIClient: logsAPIClient,
      cryptoEngine: cryptoEngine,
      storeURL: storeURL,
      flushLocalStoreImmediately: spaceIdWithActivtyLogsEnabled != nil,
      logger: logger)
  }

  private func validateShouldSendActivityLogs(forSpaceID spaceId: String?) throws {
    guard spaceIdWithActivtyLogsEnabled == spaceId else {
      throw TeamAuditLogError.noBusinessTeamEnabledCollection
    }
  }
}

extension TeamAuditLogsService {
  public func report(_ generateReportableInfo: @autoclosure () -> ReportableInfo?) throws {
    guard isEnabled else {
      throw TeamAuditLogError.noBusinessTeamEnabledCollection
    }
    guard let reportableInfo = generateReportableInfo() else {
      throw TeamAuditLogError.unsupportedDataType
    }
    try validateShouldSendActivityLogs(forSpaceID: reportableInfo.spaceId)

    Task {
      await self.reportService.report(reportableInfo.log)
    }
  }
}

extension TeamAuditLogsService {
  static let maxRetry = 1

  public func auditLogDetails(for logs: @autoclosure () -> [Identifier: TeamVaultAuditLog])
    async throws -> [Identifier: AuditLogDetails]
  {
    guard isEnabled else {
      return [:]
    }

    let auditLogs = logs()
      .filter {
        spaceIdWithActivtyLogsEnabled == $0.value.spaceId
      }

    guard auditLogs.isEmpty == false else {
      return [:]
    }

    var run = 0
    while run < Self.maxRetry {
      run += 1

      do {
        return try await encryptedAuditLogDetails(for: auditLogs)
      } catch let error as NitroEncryptionError
        where error.hasLogsCode(.idIsNotUnique) && run < Self.maxRetry
      {
      } catch let error as NitroEncryptionError {
        logger.fatal("Failed to encrypt audit logs", error: error)
        throw error
      } catch {
        logger.error("Failed to reach audit logs creation api", error: error)
        throw error
      }
    }

    throw EncryptionAuditLogsError.maxRetryReached
  }

  private func encryptedAuditLogDetails(for auditLogs: [Identifier: TeamVaultAuditLog]) async throws
    -> [Identifier: AuditLogDetails]
  {
    let encryptRequests = auditLogs.map { auditLog in
      let data =
        switch auditLog.value.data {
        case let .credential(domain):
          AuditLogDetailEncryptData(key: .domain, value: domain)
        }

      return AuditLogDetailEncryptRequest(
        id: auditLog.value.id.uuidString, detailsToEncrypt: [data])
    }

    let encryptedAuditLogs =
      try await logsAPIClient
      .encryptAuditLogDetailsBatchWithTeamKey(detailsToEncryptBatch: encryptRequests)
      .encryptedDetailsBatch
      .byIds()

    return try auditLogs.mapValues { auditLog -> AuditLogDetails in
      guard let encryptedDetails = encryptedAuditLogs[auditLog.id] else {
        throw EncryptionAuditLogsError.missingData(auditLog.id)
      }

      return switch auditLog.data {
      case .credential:
        AuditLogDetails(type: .authentifiant, encryptedDetails: encryptedDetails)
      }
    }
  }
}

extension [UserSecureNitroEncryptionAPIClient.Logs.EncryptAuditLogDetailsBatchWithTeamKey.Response
  .EncryptedDetailsBatchElement]
{
  fileprivate func byIds() -> [UUID: String] {
    var byIds: [UUID: String] = [:]
    for element in self {
      guard let id = UUID(uuidString: element.id) else {
        continue
      }

      byIds[id] = element.encryptedDetails
    }

    return byIds
  }
}
