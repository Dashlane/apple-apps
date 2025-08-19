import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation

actor AuditLogsReportService {
  private let logsAPIClient: UserSecureNitroEncryptionAPIClient.Logs
  private let sessionLocalStore: AuditLogsStore
  private let legacyStore: AuditLogsStore
  private let logger: Logger
  private let localFlushDelay: Duration

  private(set) var localLogsUploadTask: Task<Void, Error>?

  init(
    logsAPIClient: UserSecureNitroEncryptionAPIClient.Logs,
    cryptoEngine: CryptoEngine,
    storeURL: URL,
    flushLocalStoreImmediately: Bool = true,
    localFlushDelay: Duration = .seconds(1),
    logger: Logger
  ) {
    self.legacyStore = AuditLogsStore(
      storeURL: ApplicationGroup.activityLogsLocalStoreURL, cryptoEngine: cryptoEngine)
    self.sessionLocalStore = AuditLogsStore(storeURL: storeURL, cryptoEngine: cryptoEngine)
    self.logsAPIClient = logsAPIClient
    self.localFlushDelay = localFlushDelay
    self.logger = logger

    Task(priority: .low) {
      guard flushLocalStoreImmediately else {
        return
      }

      await flushLogs()
    }
  }
}

extension AuditLogsReportService {
  func report(_ log: TeamAuditLog, maxAttempts: Int = 3) async {
    assert(maxAttempts > 0)
    var attempLeft = maxAttempts

    while attempLeft > 0 {
      attempLeft -= 1
      do {
        logger.debug("Reporting \(log)")
        try await upload(log)
        return
      } catch {
        logger.error("Couln't upload audit log:", error: error)

        if attempLeft > 0 {
          try? await Task.sleep(for: .seconds(1))
        }
      }
    }

    store(log)
  }

  private func upload(_ log: TeamAuditLog) async throws {
    let response = try await logsAPIClient.storeAuditLogs(auditLogs: [log])
    if let invalidLog = response.invalidAuditLogs.first {
      logger.error("Invalid audit logs \(invalidLog)")
    }
  }

  private func store(_ log: TeamAuditLog) {
    do {
      try sessionLocalStore.store(log)
      setupLogsFlushTask()
    } catch {
      logger.error("Could not store the audit log locally")
    }
  }
}

extension AuditLogsReportService {
  func flushLogs() async {
    await flushLegacyLogs()
    await flushLocalSessionLogs()
  }

  private func setupLogsFlushTask() {
    logger.info("Schedule log flush")
    localLogsUploadTask?.cancel()
    self.localLogsUploadTask = Task.delayed(by: localFlushDelay, priority: .low) { [weak self] in
      await self?.flushLocalSessionLogs()
    }
  }

  private func flushLocalSessionLogs() async {
    logger.info("Flush local logs")

    do {
      try await flush(sessionLocalStore)

      localLogsUploadTask = nil
    } catch {
      logger.error("Could not upload stored audit log:", error: error)

      setupLogsFlushTask()
    }
  }

  private func flushLegacyLogs() async {
    logger.info("Flush legacy stored logs")

    do {
      try await flush(legacyStore)
    } catch {
      logger.error("Could not upload stored audit log from legacy store:", error: error)
    }
  }

  private func flush(_ store: AuditLogsStore) async throws {
    let logs = store.fetchAll()

    for logs in logs.chunked(into: 100) {
      let response = try await logsAPIClient.storeAuditLogs(auditLogs: logs)
      if !response.invalidAuditLogs.isEmpty {
        logger.error("Invalid audit logs \(response.invalidAuditLogs)")
      }

      store.removeLogs(withUUIDs: logs.map(\.uuid))
    }
  }
}
