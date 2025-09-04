import Foundation

extension Definition {

  public enum `SsoSolutionChosen`: String, Encodable, Sendable {
    case `nitroSso` = "nitro_sso"
    case `selfHostedSso` = "self_hosted_sso"
  }
}
