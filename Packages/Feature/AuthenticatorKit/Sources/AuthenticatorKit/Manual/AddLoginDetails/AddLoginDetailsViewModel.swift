import Combine
import CorePersonalData
import CoreTypes
import Foundation
import TOTPGenerator

struct NewLogin {
  var website: String
  var login: String
  var securityKey: String

  var allItemsAreFilled: Bool {
    return !website.isEmpty && !login.isEmpty && !securityKey.isEmpty
  }
}

public class AddLoginDetailsViewModel: ObservableObject, AuthenticatorServicesInjecting,
  AuthenticatorMockInjecting
{

  @Published
  var newLogin: NewLogin

  @Published
  var userCanSave: Bool = false

  @Published
  var showWrongSecretKey: Bool = false

  let credential: Credential?
  let completion: (OTPInfo) -> Void
  let supportDashlane2FA: Bool

  public init(
    website: String,
    credential: Credential?,
    supportDashlane2FA: Bool,
    completion: @escaping (OTPInfo) -> Void
  ) {
    self.newLogin = NewLogin(
      website: website,
      login: credential?.displaySubtitle ?? "",
      securityKey: "")
    self.credential = credential
    self.supportDashlane2FA = supportDashlane2FA
    self.completion = completion
    $newLogin
      .throttle(for: .milliseconds(200), scheduler: DispatchQueue.main, latest: true)
      .map({ $0.allItemsAreFilled })
      .assign(to: &$userCanSave)
  }

  func save() {
    do {
      let url = try URL.makeOTPURL(
        title: newLogin.website,
        login: newLogin.login,
        issuer: newLogin.website,
        secret: newLogin.securityKey.removeWhitespacesCharacters())
      let info = try OTPInfo(
        configuration: .init(otpURL: url, supportDashlane2FA: supportDashlane2FA))
      completion(info)
    } catch _ as URL.OTPURLError {
    } catch let error as OTPUrlParserError {
      switch error {
      case .incorrectSecret, .incorrectFormat:
        self.showWrongSecretKey = true
      default: break
      }
    } catch {
      fatalError(error.localizedDescription)
    }
  }

}

extension OTPInfo {
  fileprivate init(_ newLogin: NewLogin) throws {
    let url = try URL.makeOTPURL(
      title: newLogin.website,
      login: newLogin.login,
      issuer: newLogin.website,
      secret: newLogin.securityKey)
    try self.init(configuration: .init(otpURL: url, supportDashlane2FA: true))
  }
}

extension AddLoginDetailsViewModel {
  public static var mock: AddLoginDetailsViewModel {
    .init(
      website: "netflix.com",
      credential: nil,
      supportDashlane2FA: true,
      completion: { _ in })
  }
}
