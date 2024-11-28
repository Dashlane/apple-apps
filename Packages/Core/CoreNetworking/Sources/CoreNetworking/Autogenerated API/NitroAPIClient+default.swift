import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

extension NitroSSOAPIClient {
  public init(info: ClientInfo = .init()) throws {
    try self.init(configuration: .init(info: info, environment: .default))
  }
}
