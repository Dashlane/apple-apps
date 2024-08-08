import DashTypes
import DashlaneAPI
import Foundation

extension UnsignedAPIClient {
  public init(
    platform: Platform = .passwordManager, environment: APIConfiguration.Environment = .default
  ) throws {
    try self.init(configuration: APIConfiguration(info: .init(platform: platform)))
  }
}
