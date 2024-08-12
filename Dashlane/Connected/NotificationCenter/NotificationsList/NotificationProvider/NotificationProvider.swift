import Combine
import Foundation

protocol NotificationProvider {
  func notificationPublisher() -> AnyPublisher<[DashlaneNotification], Never>
}
