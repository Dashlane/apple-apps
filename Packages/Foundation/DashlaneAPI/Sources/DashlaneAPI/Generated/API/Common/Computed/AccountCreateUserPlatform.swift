import Foundation

public enum AccountCreateUserPlatform: String, Sendable, Equatable, CaseIterable, Codable {
  case serverCli = "server_cli"
  case serverMacosx = "server_macosx"
  case serverWin = "server_win"
  case desktopWin = "desktop_win"
  case desktopMacos = "desktop_macos"
  case serverCatalyst = "server_catalyst"
  case serverIphone = "server_iphone"
  case serverIpad = "server_ipad"
  case serverIpod = "server_ipod"
  case serverAndroid = "server_android"
  case web = "web"
  case webaccess = "webaccess"
  case realWebsite = "real_website"
  case website = "website"
  case serverCarbonTests = "server_carbon_tests"
  case serverWac = "server_wac"
  case serverTac = "server_tac"
  case serverLeeloo = "server_leeloo"
  case serverLeelooDev = "server_leeloo_dev"
  case serverStandalone = "server_standalone"
  case serverSafari = "server_safari"
  case unitaryTests = "unitary_tests"
  case userSupport = "userSupport"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
