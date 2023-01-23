import Foundation
import Combine
import CoreSession
import CorePremium

struct TwoFAEnforcementService {

    let space: Space
        let accountAPIClient: AuthenticatedAccountAPIClient
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

        let isOTP1EnabledPublisher = accountAPIClient.twoFactorStatus().map { status -> Bool in
            return status.type == .totpDeviceRegistration
        }.ignoreError()
            .eraseToAnyPublisher()
        return isOTP1EnabledPublisher
    }
}

private extension AuthenticatedAccountAPIClient {

    func twoFactorStatus() -> AnyPublisher<TwoFactorStatusResponse, Error> {
        return Future<TwoFactorStatusResponse, Error> { promise in
            twoFAStatus(completion: promise)
        }.eraseToAnyPublisher()
    }
}
