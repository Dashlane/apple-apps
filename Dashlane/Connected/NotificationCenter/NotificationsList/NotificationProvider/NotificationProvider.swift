import Foundation
import DashlaneAppKit
import Combine

protocol NotificationProvider {
    func notificationPublisher() -> AnyPublisher<[DashlaneNotification], Never>
}
