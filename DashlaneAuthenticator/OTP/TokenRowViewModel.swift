import AuthenticatorKit
import Combine
import CorePersonalData
import CoreSync
import CoreTypes
import DomainParser
import IconLibrary
import SwiftUI
import VaultKit

struct TokenRowViewModel {
  let token: OTPInfo
  let title: String
  let subtitle: String
  let isDashlaneToken: Bool
  let dashlaneTokenCaption: String

  private let domainIconLibrary: DomainIconLibraryProtocol
  private let databaseService: AuthenticatorDatabaseServiceProtocol
  private let domain: Domain?

  init(
    token: OTPInfo,
    dashlaneTokenCaption: String = "",
    domainIconLibrary: DomainIconLibraryProtocol,
    databaseService: AuthenticatorDatabaseServiceProtocol,
    domainParser: DomainParserProtocol
  ) {
    self.token = token
    self.domainIconLibrary = domainIconLibrary
    self.databaseService = databaseService
    self.subtitle = token.configuration.login.removingPercentEncoding ?? token.configuration.login
    self.title =
      token.configuration.issuerOrTitle.removingPercentEncoding ?? token.configuration.issuerOrTitle
    self.isDashlaneToken = token.isDashlaneOTP && token.configuration.login == databaseService.login
    self.dashlaneTokenCaption = dashlaneTokenCaption
    if let parsed = domainParser.parse(
      urlString: isDashlaneToken ? "dashlane.com" : token.configuration.iconURL),
      parsed.publicSuffix != nil
    {
      domain = parsed
    } else {
      domain = nil
    }
  }

  func makeDomainIconViewModel() -> DomainIconViewModel {
    return DomainIconViewModel(domain: domain, iconLibrary: domainIconLibrary)
  }

  func makeGeneratedOTPCodeRowViewModel() -> GeneratedOTPCodeRowViewModel {
    GeneratedOTPCodeRowViewModel(token: token, databaseService: databaseService)
  }
}

extension TokenRowViewModel {
  static func mock() -> TokenRowViewModel {
    TokenRowViewModel(
      token: .mock,
      domainIconLibrary: IconServiceMock().domain,
      databaseService: AuthenticatorDatabaseServiceMock(),
      domainParser: FakeDomainParser())
  }
}
