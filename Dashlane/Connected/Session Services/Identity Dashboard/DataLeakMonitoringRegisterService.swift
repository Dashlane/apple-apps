import Combine
import CoreNetworking
import CorePremium
import DashTypes
import DashlaneAPI
import Foundation
import SecurityDashboard

public protocol DataLeakMonitoringRegisterServiceProtocol {
  var monitoredEmailsPublisher: AnyPublisher<Set<DataLeakEmail>, Never> { get }
  var monitoredEmails: Set<DataLeakEmail> { get set }
  var webService: SecurityDashboard.DataLeakMonitoringService { get }
  func updateMonitoredEmails(onCompletion: ((Result<DataLeakStatusResponse, Error>) -> Void)?)
  func removeFromMonitoredEmails(email: String)
  func monitorNew(email: String) async throws
}

public final class DataLeakMonitoringRegisterService: DataLeakMonitoringRegisterServiceProtocol {

  private(set) var hasAlreadyDownloadedDataOnce = false

  public var monitoredEmailsPublisher: AnyPublisher<Set<DataLeakEmail>, Never> {
    $monitoredEmails.eraseToAnyPublisher()
  }

  @Published
  public var monitoredEmails: Set<DataLeakEmail> = []

  public let webService: SecurityDashboard.DataLeakMonitoringService
  private let logger: Logger
  private var cancellables = Set<AnyCancellable>()

  init(
    userDeviceAPIClient: UserDeviceAPIClient, notificationService: SessionNotificationService,
    logger: Logger
  ) {
    webService = userDeviceAPIClient.darkwebmonitoring
    self.logger = logger
    Task {
      notificationService.userNotificationPublisher(for: .code(.supportNotification)).onlyResponse()
        .sink { [weak self] _, completion in
          guard let self = self else {
            completion()
            return
          }
          self.updateMonitoredEmails { _ in
            completion()
          }
        }.store(in: &cancellables)
      notificationService.remoteNotificationPublisher(for: .code(.supportNotification)).sink {
        [weak self] notification in
        guard let self = self else {
          notification.completionHandler(.failed)
          return
        }
        self.updateMonitoredEmails { _ in
          notification.completionHandler(.newData)
        }
      }.store(in: &cancellables)
    }
  }

  public func updateMonitoredEmails(
    onCompletion: ((Result<DataLeakStatusResponse, Error>) -> Void)?
  ) {
    Task {
      do {
        let response = try await self.webService.listRegistrations()
        await MainActor.run {
          self.monitoredEmails = Set(response.emails)
          onCompletion?(.success(response))
        }
      } catch {
        self.logger.error("update MonitoredEmails did fail", error: error)
        await MainActor.run {
          self.monitoredEmails = []
          onCompletion?(.failure(error))
        }
      }
    }
  }

  public func removeFromMonitoredEmails(email: String) {
    self.monitoredEmails = self.monitoredEmails.filter { $0.email != email }
    Task {
      _ = try? await self.webService.deregisterEmail(email: email)
    }
  }

  public func monitorNew(email: String) async throws {
    let dataLeak = DarkwebmonitoringListEmails(pendingEmail: email)
    self.monitoredEmails.insert(dataLeak)
    _ = try? await webService.registerEmail(email: email)
  }
}
