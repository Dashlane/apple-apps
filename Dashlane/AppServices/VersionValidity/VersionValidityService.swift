import Combine
import CoreSession
import CoreSettings
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import LoginKit
import UserTrackingFoundation

class VersionValidityService {

  private let apiClient: AppAPIClient
  private let appSettings: AppSettings
  private let logger: Logger
  private let activityReporter: ActivityReporterProtocol
  private weak var logoutHandler: SessionLifeCycleHandler?

  @Published private var versionValidityStatus: VersionValidityStatus? {
    didSet {
      if versionValidityStatus != oldValue {
        versionValidityStatusToShow = versionValidityStatus
      }
    }
  }

  @Published public var versionValidityStatusToShow: VersionValidityStatus?

  init(
    apiClient: AppAPIClient, appSettings: AppSettings, logoutHandler: SessionLifeCycleHandler,
    logger: Logger, activityReporter: ActivityReporterProtocol
  ) {
    self.apiClient = apiClient
    self.appSettings = appSettings
    self.logger = logger
    self.logoutHandler = logoutHandler
    self.activityReporter = activityReporter
  }

  public func checkVersionValidity() {
    Task {
      do {
        let result = try await apiClient.platforms.appVersionStatus()
        self.versionValidityStatus = VersionValidityStatus(response: result)
      } catch let error where error.isConnectionError {
        self.versionValidityStatus = nil
      } catch {
        self.logger.error("Couldn't get app version validity status:)", error: error)
      }
    }
  }

  public func shouldShowAlertPublisher() -> AnyPublisher<VersionValidityStatus, Never> {
    return
      $versionValidityStatusToShow
      .compactMap { $0 }
      .filter { [weak self] status in
        switch status {
        case .valid:
          return false
        case .updateRecommended:
          if self?.appSettings.versionValidityAlertLastShownDate == nil {
            return true
          }

          if let alertLastShownDate = self?.appSettings.versionValidityAlertLastShownDate,
            alertLastShownDate.daysPassed > 7
          {
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

extension Date {
  fileprivate var daysPassed: Int {
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

extension VersionValidityStatus {
  fileprivate var logValue: UserEvent.ShowVersionValidityMessage? {
    switch self {
    case let .updateRecommended(updatePossible):
      return .init(isUpdatePossible: updatePossible, versionValidityStatus: .updateRecommended)
    case let .updateStronglyEncouraged(updatePossible, _):
      return .init(
        isUpdatePossible: updatePossible, versionValidityStatus: .updateStronglyEncouraged)
    case let .updateRequired(updatePossible, _, _):
      return .init(isUpdatePossible: updatePossible, versionValidityStatus: .updateRequired)
    case let .expired(updatePossible, _):
      return .init(isUpdatePossible: updatePossible, versionValidityStatus: .expiredVersion)
    case .valid:
      return nil
    }
  }
}
