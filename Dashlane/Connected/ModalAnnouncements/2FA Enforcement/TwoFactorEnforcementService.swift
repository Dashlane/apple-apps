import Foundation
import Combine
import CoreSession
import CorePremium
import DashlaneAPI

struct TwoFAEnforcementService {

    let space: Space
        let userApiClient: UserDeviceAPIClient
    let otp2Enabled: Bool

        var shouldPresent2FAEnforcement: AnyPublisher<Bool, Never> {

        guard let status = space.info.twoFAEnforced,
                status != .disabled else {
                        return Just(false).eraseToAnyPublisher()
        }

                return is2FAEnabledPublisher.map { twoFAEnabled -> Bool in
            return !twoFAEnabled
        }.eraseToAnyPublisher()
    }

        private var is2FAEnabledPublisher: AnyPublisher<Bool, Never> {
        guard !otp2Enabled else {
            return Just(true)
                .eraseToAnyPublisher()
        }

        let isOTP1EnabledPublisher = userApiClient.twoFactorStatus().map { status -> Bool in
            return status.type == .totpDeviceRegistration
        }.ignoreError()
            .eraseToAnyPublisher()
        return isOTP1EnabledPublisher
    }
}

private extension UserDeviceAPIClient {

    func twoFactorStatus() -> AnyPublisher<UserDeviceAPIClient.Authentication.Get2FAStatus.Response, Error> {
        return Future<UserDeviceAPIClient.Authentication.Get2FAStatus.Response, Error> { promise in
            Task {
                do {
                    let status = try await authentication.get2FAStatus()
                    promise(.success(status))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
