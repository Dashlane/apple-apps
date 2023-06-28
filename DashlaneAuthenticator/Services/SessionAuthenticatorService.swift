import Foundation
import Combine
import DashTypes
import CoreNetworking

class SessionAuthenticatorService {

    let apiClient: DeprecatedCustomAPIClient
    let notificationService: NotificationService
    let userDefaults: UserDefaults = UserDefaults.standard
    let authenticationRequestPublisher = PassthroughSubject<AuthenticationRequest, Never>()

    var deviceToken: Data?
    var cancellables = Set<AnyCancellable>()

    init(apiClient: DeprecatedCustomAPIClient, notificationService: NotificationService) {
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
            let input = DeviceRegistrationRequest(id: token.map { String(format: "%02x", $0) }.joined())
            let _: Empty? = try? await apiClient.sendRequest(to: "v1/authenticator/RegisterAuthenticator", using: .post, input: input)
        }
    }

    func pendingRequests() async throws -> Set<AuthenticationRequest> {
        struct Response: Decodable {
            let requests: [AuthenticationRequest]
        }
        let pendingRequests: Response = try await apiClient.sendRequest(to: "v1/authenticator/GetPendingRequests", using: .post, input: Empty())
        return Set(pendingRequests.requests)
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
