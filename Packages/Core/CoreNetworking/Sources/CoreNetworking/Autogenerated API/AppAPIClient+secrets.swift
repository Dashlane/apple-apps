import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

extension AppAPIClient {
  public init(configuration: APIConfiguration) {
    let appCredentials = DashlaneAPI.AppCredentials(
      accessKey: ApplicationSecrets.Server.apiKey,
      secretKey: ApplicationSecrets.Server.apiSecret)

    self.init(configuration: configuration, appCredentials: appCredentials)
  }

  public init(
    platform: Platform = .passwordManager, environment: APIConfiguration.Environment = .default
  ) throws {
    try self.init(
      configuration: APIConfiguration(info: .init(platform: platform), environment: environment))
  }
}
