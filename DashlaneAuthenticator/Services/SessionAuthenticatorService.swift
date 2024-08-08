import Combine
import DashTypes
import DashlaneAPI
import Foundation

class SessionAuthenticatorService {

  let apiClient: UserDeviceAPIClient
  let notificationService: NotificationService
  let userDefaults: UserDefaults = UserDefaults.standard
  let authenticationRequestPublisher = PassthroughSubject<AuthenticationRequest, Never>()

  var deviceToken: Data?
  var cancellables = Set<AnyCancellable>()

  init(apiClient: UserDeviceAPIClient, notificationService: NotificationService) {
    self.apiClient = apiClient
    self.notificationService = notificationService

    subscribeToDeviceTokenPublisher()
  }

  private func subscribeToDeviceTokenPublisher() {
    self.notificationService.remoteDeviceTokenPublisher()
      .map { Optional($0) }
      .sink { [weak self] token in
        self?.deviceToken = token
        if token != nil {
          self?.registerDeviceToken()
        }
      }
      .store(in: &cancellables)
  }

  func registerDeviceToken() {
    guard let token = deviceToken else {
      return
    }
    Task {
      let id = token.map { String(format: "%02x", $0) }.joined()
      try await apiClient.authenticator.registerAuthenticator(
        push: .init(pushId: id, platform: .apn))
    }
  }

  func pendingRequests() async throws -> Set<AuthenticationRequest> {
    return try await Set(apiClient.authenticator.getPendingRequests().requests)
  }
}

struct DeviceRegistrationRequest: Encodable {

  let push: PushInfo

  init(id: String) {
    self.push = PushInfo(pushId: id, platform: "apn")
  }
}

struct PushInfo: Encodable {
  let pushId: String
  let platform: String
}

private struct Empty: Codable {}
