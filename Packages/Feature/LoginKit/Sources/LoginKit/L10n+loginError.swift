import CoreLocalization
import CoreSession
import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

extension L10n {
  public static func errorMessage(for error: Error) -> String {
    switch error {
    case let urlError as URLError where urlError.code == .notConnectedToInternet:
      return L10n.Core.kwNoInternet
    case LoginHandler.Error.loginDoesNotExist:
      return L10n.Core.accountDoesNotExist
    case let error as DashlaneAPI.APIError
    where error.hasAuthenticationCodes([
      .verificationFailed, .invalidOTPAlreadyUsed, .verificationRequiresRequest,
      .accountBlockedContactSupport,
    ]):
      return L10n.Core.badToken
    case ThirdPartyOTPError.wrongOTP:
      return L10n.Core.badToken
    case ThirdPartyOTPError.duoChallengeFailed:
      return L10n.Core.duoChallengeFailedMessage
    case RemoteLoginHandler.Error.wrongMasterKey, LocalLoginHandler.Error.wrongMasterKey:
      return L10n.Core.kwWrongMasterPasswordTryAgain
    case let error as DashlaneAPI.APIError where error.hasAccountCode(.accountAlreadyExists):
      return L10n.Core.kwAccountCreationExistingAccount
    case AccountError.userNotFound:
      return L10n.Core.accountDoesNotExist
    case let error as DashlaneAPI.APIError where error.hasInvalidRequestCode(.requestMalformed):
      return L10n.Core.kwEmailInvalid
    case AccountError.invalidEmail,
      AccountCreationError.invalidEmail,
      AccountError.invalidInput,
      AccountExistsError.invalidValue,
      AccountExistsError.unlikelyValue:
      return L10n.Core.kwEmailInvalid
    case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.verificationTimeout):
      return L10n.Core.kwAccountErrorTimeOut
    case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.invalidOTPBlocked):
      return L10n.Core.kwThrottleMsg
    case let error as DashlaneAPI.APIError
    where error.hasAuthenticationCode(.accountBlockedContactSupport):
      return L10n.Core.kwpasswordchangererrorAccountLocked
    case let error as DashlaneAPI.APIError where error.hasAccountCode(.ssoBlocked):
      return L10n.Core.ssoBlockedError
    case let error as DashlaneAPI.APIError where error.hasAccountCode(.phoneValidationFailed):
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
