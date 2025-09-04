import Foundation

extension UserEvent {

  public struct `SetupMassDeployment`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `massDeploymentSetupBrowserList`: [Definition.MassDeploymentSetupBrowser]? = nil,
      `massDeploymentSetupMethod`: Definition.MassDeploymentSetupMethod? = nil,
      `massDeploymentSetupStep`: Definition.MassDeploymentSetupStep
    ) {
      self.massDeploymentSetupBrowserList = massDeploymentSetupBrowserList
      self.massDeploymentSetupMethod = massDeploymentSetupMethod
      self.massDeploymentSetupStep = massDeploymentSetupStep
    }
    public let massDeploymentSetupBrowserList: [Definition.MassDeploymentSetupBrowser]?
    public let massDeploymentSetupMethod: Definition.MassDeploymentSetupMethod?
    public let massDeploymentSetupStep: Definition.MassDeploymentSetupStep
    public let name = "setup_mass_deployment"
  }
}
