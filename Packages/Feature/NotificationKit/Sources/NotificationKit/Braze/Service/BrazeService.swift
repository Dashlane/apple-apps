import BrazeKit
import BrazeUI
import Combine
import CoreFeature
import CoreSettings
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import UserNotifications

public protocol BrazeServiceProtocol {
  func registerLogin(
    _ login: Login,
    using userSettings: UserSettings,
    userDeviceAPIClient: UserDeviceAPIClient,
    featureService: FeatureServiceProtocol) async
  func registerForNotifications(deviceToken: Data)
  func didReceive(notification: UNNotificationResponse, completion: @escaping () -> Void)
  var modals: [BrazeAnnouncement] { get }
  var modalsPublisher: Published<[BrazeAnnouncement]>.Publisher { get }
}

public class BrazeService: BrazeServiceProtocol {

  internal var braze: Braze?

  let logger: Logger

  public var modalsPublisher: Published<[BrazeAnnouncement]>.Publisher {
    return $modals
  }

  @Published
  public internal(set) var modals: [BrazeAnnouncement] = []

  public init(logger: Logger) {
    self.logger = logger

    if ProcessInfo.isTesting && !ProcessInfo.keepBrazeService {
      braze = nil
      return
    } else {
      DispatchQueue.global(qos: .utility).async {
        self.braze = .init(configuration: .default)
        DispatchQueue.main.async {
          self.braze?.inAppMessagePresenter = self
        }
      }
    }

  }

  public func registerForNotifications(deviceToken: Data) {
    braze?.notifications.register(deviceToken: deviceToken)
  }

  public func didReceive(notification: UNNotificationResponse, completion: @escaping () -> Void) {
    _ = braze?.notifications.handleUserNotification(
      response: notification, withCompletionHandler: completion)
  }

  func shouldLinkBrazeToUser(featureService: FeatureServiceProtocol) -> Bool {
    guard featureService.isEnabled(.brazeInAppMessageIsAvailable) else {
      disableBraze()
      return false
    }
    if let braze, !braze.enabled {
      braze.enabled = true
    }
    return true

  }
  private func disableBraze() {
    modals = []
    braze?.inAppMessagePresenter = nil
    braze?.wipeData()
  }
}

extension Braze.Configuration {
  fileprivate static var `default`: Braze.Configuration {
    var configuration = Braze.Configuration(
      apiKey: ApplicationSecrets.Braze.token,
      endpoint: "sdk.iad-01.braze.com")
    configuration.devicePropertyAllowList = [.pushEnabled, .pushAuthStatus, .locale, .timeZone]
    #if DEBUG
      configuration.logger.level = .error
    #else
      configuration.logger.level = .disabled
    #endif
    return configuration
  }
}

extension BrazeService {
  public static var mock: BrazeServiceProtocol {
    return BrazeServiceMock()
  }
}

class BrazeServiceMock: BrazeServiceProtocol {

  public var modalsPublisher: Published<[BrazeAnnouncement]>.Publisher {
    return $modals
  }

  @Published
  public var modals: [BrazeAnnouncement] = []

  public init() {

  }

  public func registerLogin(
    _ login: Login, using userSettings: UserSettings, userDeviceAPIClient: UserDeviceAPIClient,
    featureService: FeatureServiceProtocol
  ) async {

  }

  public func registerForNotifications(deviceToken: Data) {

  }

  public func didReceive(notification: UNNotificationResponse, completion: @escaping () -> Void) {
    completion()
  }
}

extension ProcessInfo {
  public static var keepBrazeService: Bool {
    #if DEBUG
      return ProcessInfo.processInfo.arguments.contains("-keepBrazeData")
    #else
      return true
    #endif
  }
}
