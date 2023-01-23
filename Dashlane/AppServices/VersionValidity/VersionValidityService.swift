import Foundation
import CoreNetworking
import DashTypes
import Combine
import CoreSession
import DashlaneAppKit
import CoreUserTracking
import LoginKit

class VersionValidityService {

    private let apiClient: DeprecatedCustomAPIClient
    private let appSettings: AppSettings
    private let logger: Logger
    private let activityReporter: ActivityReporterProtocol
    private weak var logoutHandler: SessionLifeCycleHandler?

    private let endpoint = "/v1/platforms/AppVersionStatus"

        @Published private var versionValidityStatus: VersionValidityStatus? {
        didSet {
                        if versionValidityStatus != oldValue {
                versionValidityStatusToShow = versionValidityStatus
            }
        }
    }

        @Published public var versionValidityStatusToShow: VersionValidityStatus?

    init(apiClient: DeprecatedCustomAPIClient, appSettings: AppSettings, logoutHandler: SessionLifeCycleHandler, logger: Logger, activityReporter: ActivityReporterProtocol) {
        self.apiClient = apiClient
        self.appSettings = appSettings
        self.logger = logger
        self.logoutHandler = logoutHandler
        self.activityReporter = activityReporter
    }

    public func checkVersionValidity() {
        struct Empty: Encodable {}
        DispatchQueue.global(qos: .utility).async {
            self.apiClient.sendRequest(to: self.endpoint, using: .post, input: Empty()) { [weak self] (result: Result<VersionValidityStatusServerResponse, Error>) in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.versionValidityStatus = VersionValidityStatus(fromServerResponse: response)
                case .failure(let error) where error.isConnectionError:
                    self.versionValidityStatus = nil
                case .failure(let error):
                    if case .parseError(let decodingError) = (error as? ResourceError) {
                        self.logger.error(decodingError.debugDescription)
                        return
                    }
                    self.logger.error(String(describing: error))
                }
            }
        }
    }

    public func shouldShowAlertPublisher() -> AnyPublisher<VersionValidityStatus, Never> {
        return $versionValidityStatusToShow
            .compactMap { $0 }
            .filter { [weak self] status in
                switch status {
                case .valid:
                    return false
                case .updateRecommended:
                                        if self?.appSettings.versionValidityAlertLastShownDate == nil {
                        return true
                    }

                                        if let alertLastShownDate = self?.appSettings.versionValidityAlertLastShownDate, alertLastShownDate.daysPassed > 7 {
                        return true
                    }

                    return false
                case .updateStronglyEncouraged, .updateRequired, .expired:
                                        return true
                }
            }
            .eraseToAnyPublisher()
    }

    public func messageShown(for status: VersionValidityStatus) {
        appSettings.versionValidityAlertLastShownDate = Date()
        versionValidityStatusToShow = nil
        logMessageShown(for: status)
    }

    public func messageDismissed(for status: VersionValidityStatus) {
        if case .expired = status {
            logger.warning("This version is expired. The user must be be logged out.")
            logoutHandler?.logoutAndPerform(action: .deleteCurrentSessionLocalData)
        }
    }

    private func logMessageShown(for status: VersionValidityStatus) {
        guard let event = status.logValue else {
            logger.error("Error: Unexpected attempt to log a message for a valid version.")
            return
        }

        activityReporter.report(event)
    }
}

private extension Date {
    var daysPassed: Int {
        let now: Date = {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-eightDaysIntoTheFuture") {
                return Calendar.current.date(byAdding: .day, value: 8, to: Date())!
            }
            #endif

            return Date()
        }()

        return Calendar.current.dateComponents([.day], from: self, to: now).day ?? 0
    }
}

private extension VersionValidityStatus {
    var logValue: UserEvent.ShowVersionValidityMessage? {
        switch self {
        case let .updateRecommended(updatePossible):
            return .init(isUpdatePossible: updatePossible, versionValidityStatus: .updateRecommended)
        case let .updateStronglyEncouraged(updatePossible, _):
            return .init(isUpdatePossible: updatePossible, versionValidityStatus: .updateStronglyEncouraged)
        case let .updateRequired(updatePossible, _, _):
            return .init(isUpdatePossible: updatePossible, versionValidityStatus: .updateRequired)
        case let .expired(updatePossible, _):
            return .init(isUpdatePossible: updatePossible, versionValidityStatus: .expiredVersion)
        case .valid:
            return nil
        }
    }
}
