import Combine
import CoreNetworking
import CorePersonalData
import CoreTypes
import Foundation
import TOTPGenerator
import UserTrackingFoundation
import VaultKit

extension AddOTPFlowViewModel {
  func logOTPAdded(
    _ configuration: OTPConfiguration, to credential: Credential,
    by additionMode: Definition.OtpAdditionMode
  ) {

    activityReporter.report(
      UserEvent.AddTwoFactorAuthenticationToCredential(
        flowStep: .complete,
        itemId: credential.userTrackingLogID,
        otpAdditionMode: additionMode,
        space: credential.userTrackingSpace
      ))

    activityReporter.report(
      AnonymousEvent.AddTwoFactorAuthenticationToCredential(
        domain: credential.hashedDomainForLogs(),
        flowStep: .complete,
        otpAdditionMode: additionMode,
        otpSpecifications: configuration.specifications,
        space: credential.userTrackingSpace
      ))

    activityReporter.report(
      AnonymousEvent.UpdateCredential(
        action: .edit,
        associatedWebsitesAddedList: [],
        associatedWebsitesRemovedList: [],
        credentialOriginalSecurityStatus: nil,
        credentialSecurityStatus: nil,
        domain: credential.hashedDomainForLogs(),
        fieldList: [.otpSecret],
        isCredentialCurrentlyEligibleToPasswordChanger: nil,
        space: credential.userTrackingSpace,
        updateCredentialOrigin: .manual
      ))
  }

  func logOTPAdditionStarted(
    for additionMode: Definition.OtpAdditionMode, to credential: Credential?
  ) {
    let userEvent = UserEvent.AddTwoFactorAuthenticationToCredential(
      flowStep: .start,
      itemId: credential?.userTrackingLogID,
      otpAdditionMode: additionMode,
      space: credential?.userTrackingSpace
    )

    activityReporter.report(userEvent)
  }

  func logOTPAdditionFailure(
    by additionMode: Definition.OtpAdditionMode, to credential: Credential?,
    error: Definition.OtpAdditionError
  ) {
    let userEvent = UserEvent.AddTwoFactorAuthenticationToCredential(
      flowStep: .error,
      itemId: credential?.userTrackingLogID,
      otpAdditionMode: additionMode,
      space: credential?.userTrackingSpace
    )

    activityReporter.report(userEvent)
  }
}

extension OTPConfiguration {

  fileprivate var specifications: Definition.OtpSpecifications {
    return .init(
      durationOtpValidity: type.validityDuration,
      encryptionAlgorithm: algorithm.userTrackingAlgorithm, otpCodeSize: digits,
      otpIncrementCount: type.incrementCount, otpType: type.userTrackingType)
  }
}

extension OTPType {
  fileprivate var validityDuration: Int? {
    guard case let .totp(period) = self else {
      return nil
    }
    return Int(period)
  }

  fileprivate var incrementCount: Int? {
    guard case let .hotp(counter) = self else {
      return nil
    }
    return Int(counter)
  }

  fileprivate var userTrackingType: Definition.OtpType {
    switch self {
    case .hotp:
      return .hotp
    case .totp:
      return .totp
    }
  }
}

extension HashAlgorithm {
  fileprivate var userTrackingAlgorithm: Definition.EncryptionAlgorithm {
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
