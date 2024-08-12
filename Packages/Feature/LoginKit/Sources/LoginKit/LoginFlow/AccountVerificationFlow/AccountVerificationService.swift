import CoreSession
import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

public class AccountVerificationService {

  let login: String
  private let appAPIClient: AppAPIClient
  private let deviceInfo: DeviceInfo

  init(
    login: Login,
    appAPIClient: AppAPIClient,
    deviceInfo: DeviceInfo
  ) {
    self.login = login.email
    self.appAPIClient = appAPIClient
    self.deviceInfo = deviceInfo
  }

  public func requestToken() async throws {
    _ = try await appAPIClient.authentication.requestEmailTokenVerification(login: login)
  }

  public func qaToken() async throws -> String {
    return try await appAPIClient.authenticationQA.getDeviceRegistrationTokenForTestLogin(
      login: login
    ).token
  }

  public func validateToken(_ token: String) async throws -> AuthTicket {
    let verificationResponse = try await self.appAPIClient.authentication
      .performEmailTokenVerification(login: login, token: token)
    return AuthTicket(value: verificationResponse.authTicket)
  }

  public func validateUsingAuthenticatorPush() async throws -> AuthTicket {
    let verificationResponse = try await self.appAPIClient.authentication
      .performDashlaneAuthenticatorVerification(login: login)
    return AuthTicket(value: verificationResponse.authTicket)
  }

  public func validateOTP(_ otp: String) async throws -> AuthTicket {
    let verificationResponse = try await self.appAPIClient.authentication.performTotpVerification(
      login: login, otp: otp)
    return AuthTicket(value: verificationResponse.authTicket)
  }

  public func validateUsingDUOPush() async throws -> AuthTicket {
    let verificationResponse = try await self.appAPIClient.authentication
      .performDuoPushVerification(login: login)
    return AuthTicket(value: verificationResponse.authTicket)
  }

}

extension AccountVerificationService {
  static var mock: AccountVerificationService {
    AccountVerificationService(login: "_", appAPIClient: .fake, deviceInfo: .mock)
  }
}
