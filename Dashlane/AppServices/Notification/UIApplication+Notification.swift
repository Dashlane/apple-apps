import Foundation
import Combine
import UIKit

extension UIApplication {
        static let remoteDeviceTokenPublisher = PassthroughSubject<Data, Error>()
        static let remoteNotificationPublisher = PassthroughSubject<RemoteNotification, Never>()
        static let menubarPublisher = PassthroughSubject<UIMenuBuilder, Never>()
}
