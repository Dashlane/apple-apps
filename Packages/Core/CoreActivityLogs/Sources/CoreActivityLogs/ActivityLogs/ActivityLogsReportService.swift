import Foundation
import DashTypes
import DashlaneAPI

class ActivityLogsReportService {

    private let uploader: ActivityLogsUploader
    private let localStore: ActivityLogsStore
    private let logger: Logger
    private let localFlushDelay: Double

        private(set) var localLogsUploadTask: Task<Void, Error>?

    init(apiClient: UserDeviceAPIClient.Teams.StoreActivityLogs,
         cryptoEngine: CryptoEngine,
         storeURL: URL = ApplicationGroup.activityLogsLocalStoreURL,
         localFlushDelay: Double = 60 * 1, 
         logger: Logger) {
        self.uploader = ActivityLogsUploader(apiClient: apiClient, logger: logger)
        self.localStore = ActivityLogsStore(storeURL: storeURL,
                                            cryptoEngine: cryptoEngine)
        self.localFlushDelay = localFlushDelay
        self.logger = logger
        if !localStore.isEmpty() {
                        setupLogsFlushTask(delay: 0)
        }
    }
}

extension ActivityLogsReportService {

    func report(_ log: ActivityLog, maxAttempts: Int = 3) async {
        assert(maxAttempts > 0)
        for _ in 0..<maxAttempts {
            do {
                logger.debug("Reporting \(log)")
                try await uploader.upload(log)
                                return
            } catch let ActivityLogsUploader.Error.couldNotUploadLogs(error) {
                logger.error("Couln't upload activity log \(error.localizedDescription)")
            } catch {
                return
            }
        }

                do {
            try localStore.store(log)
            setupLogsFlushTask(delay: localFlushDelay)
        } catch {
            logger.fatal("Could not store the activity log locally")
        }
    }
}

extension ActivityLogsReportService {

    private func setupLogsFlushTask(delay: TimeInterval) {
        self.localLogsUploadTask = Task.delayed(by: delay, operation: {
            try? await flushLogs()
        })
    }

    func flushLogs() async throws {
        let fetchedLogs = try localStore.fetchAll()
        for fetchedLog in fetchedLogs {
            do {
                                try await uploader.upload(fetchedLog)
                                localStore.removeLogs(withUUIDs: [fetchedLog.uuid])
            } catch let ActivityLogsUploader.Error.couldNotUploadLogs(error) {
                logger.error("Could not upload stored activity log \(error.localizedDescription)")
            } catch {
                return
            }
        }

    }
}
