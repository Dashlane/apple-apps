import Foundation
import DashTypes
import CoreLocalization
import CoreSession
import SwiftTreats

extension L10n {
        public static func errorMessage(for error: Error) -> String {
        switch error {
        case let urlError as URLError where urlError.code == .notConnectedToInternet:
            return L10n.Core.kwNoInternet
        case LoginHandler.Error.loginDoesNotExist:
            return L10n.Core.accountDoesNotExist
        case ThirdPartyOTPError.wrongOTP,
             AccountError.verificationDenied,
             AccountError.invalidOtpAlreadyUsed,
             AccountError.verificationRequiresRequest:
            return L10n.Core.badToken
        case ThirdPartyOTPError.duoChallengeFailed:
            return L10n.Core.duoChallengeFailedMessage
        case RemoteLoginHandler.Error.wrongMasterKey, LocalLoginHandler.Error.wrongMasterKey:
            return L10n.Core.kwWrongMasterPasswordTryAgain
        case AccountError.alreadyExists:
            return L10n.Core.kwAccountCreationExistingAccount
        case AccountError.userNotFound:
            return L10n.Core.accountDoesNotExist
        case AccountError.invalidEmail, AccountCreationError.invalidEmail, AccountError.invalidInput, AccountExistsError.invalidValue, AccountExistsError.unlikelyValue, AccountError.malformed:
            return L10n.Core.kwEmailInvalid
        case AccountError.verificationtimeOut:
            return L10n.Core.kwAccountErrorTimeOut
        case AccountError.tooManyAttempts:
            return L10n.Core.tooManyTokenAttempts
        case AccountError.rateLimitExceeded,
             AccountError.invalidOtpBlocked:
            return L10n.Core.kwThrottleMsg
        case AccountError.accountBlocked:
            return L10n.Core.kwpasswordchangererrorAccountLocked
        case AccountError.ssoBlocked:
            return L10n.Core.ssoBlockedError
        case AccountError.invalidRecoveryPhoneNumber:
            return L10n.Core.invalidRecoveryPhoneNumberErrorMessage
        default:
            if DiagnosticMode.isEnabled {
                return error.debugDescription
            } else {
                return L10n.Core.kwExtSomethingWentWrong
            }
        }
    }
}
