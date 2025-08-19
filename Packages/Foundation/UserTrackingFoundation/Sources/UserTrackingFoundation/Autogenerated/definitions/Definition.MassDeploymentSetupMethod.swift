import Foundation

extension Definition {

  public enum `MassDeploymentSetupMethod`: String, Encodable, Sendable {
    case `gpo`
    case `intune`
    case `jamf`
  }
}
