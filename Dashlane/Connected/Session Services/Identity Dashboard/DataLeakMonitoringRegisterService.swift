import Foundation
import SecurityDashboard
import CorePremium
import DashTypes
import CoreNetworking
import Combine

public final class DataLeakMonitoringRegisterService: Mockable {

    private(set) var hasAlreadyDownloadedDataOnce = false
    private(set) var canShowDataLeakFeature = false

    public var monitoredEmailsPublisher: AnyPublisher<Set<DataLeakEmail>, Never> { $monitoredEmails.eraseToAnyPublisher()
    }

    @Published
    public var monitoredEmails: Set<DataLeakEmail> = []  

    public let webService: SecurityDashboard.DataLeakMonitoringService
    private let logger: Logger
    private var cancellables = Set<AnyCancellable>()

    init(webservice: LegacyWebService, notificationService: SessionNotificationService, logger: Logger) {
        webService = SecurityDashboard.DataLeakMonitoringService(webservice: webservice)
        self.logger = logger
        Task {
            await notificationService.userNotificationPublisher(for: .code(.supportNotification)).onlyResponse().sink { [weak self] _, completion in
                guard let self = self else {
                    completion()
                    return
                }
                self.updateMonitoredEmails { _ in
                    completion()
                }
            }.store(in: &cancellables)
            await notificationService.remoteNotificationPublisher(for: .code(.supportNotification)).sink { [weak self] notification in
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

    public func updateMonitoredEmails(onCompletion: ((Result<DataLeakMonitoringStatusResponse, Error>) -> Void)?) {
        Task {
            do {
                let response = try await self.webService.status()
                await MainActor.run {
                    self.canShowDataLeakFeature = true
                    self.monitoredEmails = response.emails
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

    public func removeFromMonitoredEmails(emails: [String]) {
        self.monitoredEmails = self.monitoredEmails.filter({ !emails.contains($0.email) })
        Task {
            _ = try? await self.webService.unregister(emails: emails)
        }
    }

    public func monitorNew(email: String) {
        let dataLeak = DataLeakEmail(email)
        self.monitoredEmails.insert(dataLeak)
    }
}
