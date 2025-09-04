import CoreTypes
import Foundation

struct TestAccountInfo: AccountInfo {
  let email: String
  let loginType: AccountLoginType
  let comment: String?

  var subtitle: String? {
    [loginType.subtitle, comment]
      .compactMap { $0 }
      .joined(separator: " - ")
  }
}

extension TestAccountInfo {
  static let testAccounts: [TestAccountInfo] = [
    .init(
      email: TestAccount.accountPrefix + "_",
      loginType: .otp(type: .otp1),
      comment: "Personal test account"),
    .init(
      email: TestAccount.accountPrefix + "_",
      loginType: .sso,
      comment: "Okta provider"),
    .init(
      email: TestAccount.accountPrefix + "_",
      loginType: .otp(type: .otp2),
      comment: nil),
    .init(
      email: TestAccount.accountPrefix + "_",
      loginType: .sso,
      comment: nil),
  ]
}
