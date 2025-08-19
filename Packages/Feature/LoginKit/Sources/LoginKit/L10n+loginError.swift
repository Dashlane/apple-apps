import CoreLocalization
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import SwiftTreats

extension CoreL10n {
  public static func errorMessage(for error: Error) -> String {
    switch error {
    case let urlError as URLError where urlError.code == .notConnectedToInternet:
      return CoreL10n.kwNoInternet
    case LoginStateMachine.Error.loginDoesNotExist:
      return CoreL10n.accountDoesNotExist
    case let error as DashlaneAPI.APIError
    where error.hasAuthenticationCodes([
      .verificationFailed, .invalidOTPAlreadyUsed, .verificationRequiresRequest,
      .accountBlockedContactSupport,
    ]):
      return CoreL10n.badToken
    case ThirdPartyOTPError.wrongOTP:
      return CoreL10n.badToken
    case ThirdPartyOTPError.duoChallengeFailed:
      return CoreL10n.duoChallengeFailedMessage
    case RemoteLoginStateMachine.Error.wrongMasterKey, LocalLoginStateMachine.Error.wrongMasterKey,
      MasterPasswordLocalLoginStateMachine.Error.wrongMasterKey:
      return CoreL10n.kwWrongMasterPasswordTryAgain
    case let error as DashlaneAPI.APIError where error.hasAccountCode(.accountAlreadyExists):
      return CoreL10n.kwAccountCreationExistingAccount
    case AccountError.userNotFound:
      return CoreL10n.accountDoesNotExist
    case let error as DashlaneAPI.APIError where error.hasInvalidRequestCode(.requestMalformed):
      return CoreL10n.kwEmailInvalid
    case AccountError.invalidEmail,
      AccountCreationError.invalidEmail,
      AccountError.invalidInput,
      AccountExistsError.invalidValue,
      AccountExistsError.unlikelyValue:
      return CoreL10n.kwEmailInvalid
    case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.verificationTimeout):
      return CoreL10n.kwAccountErrorTimeOut
    case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.invalidOTPBlocked):
      return CoreL10n.kwThrottleMsg
    case let error as DashlaneAPI.APIError
    where error.hasAuthenticationCode(.accountBlockedContactSupport):
      return CoreL10n.kwpasswordchangererrorAccountLocked
    case let error as DashlaneAPI.APIError where error.hasAccountCode(.ssoBlocked):
      return CoreL10n.ssoBlockedError
    case let error as DashlaneAPI.APIError where error.hasAccountCode(.phoneValidationFailed):
      return CoreL10n.invalidRecoveryPhoneNumberErrorMessage
    default:
      if DiagnosticMode.isEnabled {
        return error.debugDescription
      } else {
        return CoreL10n.kwExtSomethingWentWrong
      }
    }
  }
}
