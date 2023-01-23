import Foundation
import DashTypes
import CoreNetworking
import DashlaneAppKit
import Combine
import TOTPGenerator
import CorePersonalData
import CoreUserTracking
import VaultKit

extension AddOTPFlowViewModel {
    func logOTPAdded(_ configuration: OTPConfiguration, to credential: Credential, by additionMode: Definition.OtpAdditionMode) {
        let userEvent = UserEvent.AddTwoFactorAuthenticationToCredential(
            flowStep: .complete,
            itemId: credential.userTrackingLogID,
            otpAdditionMode: additionMode,
            space: credential.userTrackingSpace
        )
        let anonymousEvent = AnonymousEvent.AddTwoFactorAuthenticationToCredential(
            domain: credential.hashedDomainForLogs,
            flowStep: .complete,
            otpAdditionMode: additionMode,
            otpSpecifications: configuration.specifications,
            space: credential.userTrackingSpace
        )
        let updateCredential = AnonymousEvent.UpdateCredential(
            action: .edit,
            associatedWebsitesAddedList: [],
            associatedWebsitesRemovedList: [],
            credentialOriginalSecurityStatus: nil,
            credentialSecurityStatus: nil,
            domain: credential.hashedDomainForLogs,
            fieldList: [.otpSecret],
            isCredentialCurrentlyEligibleToPasswordChanger: nil,
            space: credential.userTrackingSpace,
            updateCredentialOrigin: .manual
        )

        activityReporter.report(userEvent)
        activityReporter.report(anonymousEvent)
        activityReporter.report(updateCredential)
    }

    func logOTPAdditionStarted(for additionMode: Definition.OtpAdditionMode, to credential: Credential?) {
        let userEvent = UserEvent.AddTwoFactorAuthenticationToCredential(
            flowStep: .start,
            itemId: credential?.userTrackingLogID,
            otpAdditionMode: additionMode,
            space: credential?.userTrackingSpace
        )

        activityReporter.report(userEvent)
    }

    func logOTPAdditionFailure(by additionMode: Definition.OtpAdditionMode, to credential: Credential?, error: Definition.OtpAdditionError) {
        let userEvent = UserEvent.AddTwoFactorAuthenticationToCredential(
            flowStep: .error,
            itemId: credential?.userTrackingLogID,
            otpAdditionMode: additionMode,
            space: credential?.userTrackingSpace
        )

        activityReporter.report(userEvent)
    }
}

private extension OTPConfiguration {

    var specifications: Definition.OtpSpecifications {
        return .init(durationOtpValidity: type.validityDuration, encryptionAlgorithm: algorithm.userTrackingAlgorithm, otpCodeSize: digits, otpIncrementCount: type.incrementCount, otpType: type.userTrackingType)
    }
}

private extension OTPType {
    var validityDuration: Int? {
        guard case let .totp(period) = self else {
            return nil
        }
        return Int(period)
    }

    var incrementCount: Int? {
        guard case let .hotp(counter) = self else {
            return nil
        }
        return Int(counter)
    }

    var userTrackingType: Definition.OtpType {
        switch self {
        case .hotp:
            return .hotp
        case .totp:
            return .totp
        }
    }
}

private extension HashAlgorithm {
    var userTrackingAlgorithm: Definition.EncryptionAlgorithm {
        switch self {
        case .sha1:
            return .sha1
        case .sha256:
            return .sha256
        case .sha512:
            return .sha512
        }
    }
}
