import Foundation

extension Definition {

  public enum `IntegrationPlatform`: String, Encodable, Sendable {
    case `dashlaneExtension` = "dashlane_extension"
    case `global`
    case `inContext` = "in_context"
    case `slack`
  }
}
