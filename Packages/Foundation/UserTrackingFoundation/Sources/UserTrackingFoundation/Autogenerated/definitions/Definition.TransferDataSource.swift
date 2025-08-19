import Foundation

extension Definition {

  public enum `TransferDataSource`: String, Encodable, Sendable {
    case `source1Password` = "source_1password"
    case `sourceApplePasswords` = "source_apple_passwords"
    case `sourceBitwarden` = "source_bitwarden"
    case `sourceChrome` = "source_chrome"
    case `sourceDash` = "source_dash"
    case `sourceEdge` = "source_edge"
    case `sourceFirefox` = "source_firefox"
    case `sourceKeepass` = "source_keepass"
    case `sourceKeeper` = "source_keeper"
    case `sourceKeychain` = "source_keychain"
    case `sourceLastpass` = "source_lastpass"
    case `sourceOther` = "source_other"
    case `sourceSafari` = "source_safari"
    case `sourceUrlsForAllowlist` = "source_urls_for_allowlist"
  }
}
