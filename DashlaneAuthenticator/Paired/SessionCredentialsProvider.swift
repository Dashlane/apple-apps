import AuthenticatorKit
import CorePersonalData
import Foundation
import SwiftUI
import VaultKit

protocol SessionCredentialsProvider {
  var credentialsPublisher: Published<[Credential]>.Publisher { get }
  func credentialsWithFullRights() async -> [Credential]
  func link(_ otpInfo: OTPInfo, to credential: Credential) throws
}

extension SessionCredentialsProvider {
  func matchingCredentialsFor(_ otpInfo: OTPInfo) async -> [Credential] {
    let issuer = otpInfo.configuration.issuer ?? otpInfo.configuration.title
    return await matchingCredentialsFor(issuer)
  }

  func matchingCredentialsFor(_ website: String) async -> [Credential] {
    guard !website.isEmpty else {
      return []
    }
    let credentials = await self.credentialsWithFullRights()
      .matchingCredentials(forDomain: website)
      .filterCredentialsHavingOTPSet()

    return credentials
  }
}

class CredentialsProviderMock: SessionCredentialsProvider {

  @Published
  var credentials = PersonalDataMock.Credentials.all

  var credentialsPublisher: Published<[Credential]>.Publisher {
    $credentials
  }

  func credentialsWithFullRights() async -> [Credential] {
    return credentials
  }

  func link(_ otpInfo: OTPInfo, to credential: Credential) throws {

  }
}
