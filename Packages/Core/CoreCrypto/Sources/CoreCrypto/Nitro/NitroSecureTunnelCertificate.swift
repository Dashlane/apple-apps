import CoreTypes
import Foundation

public struct NitroSecureTunnelCertificate: Sendable {

  public static let prod = NitroSecureTunnelCertificate(
    rootCertificate: ApplicationSecrets.NitroSSO.rootCertificate,
    pcr3: ApplicationSecrets.NitroSSO.pcr3,
    pcr8: ApplicationSecrets.NitroSSO.pcr8)

  public let rootCertificate: String

  public let pcr3: String

  public let pcr8: String

  public init(rootCertificate: String, pcr3: String, pcr8: String) {
    self.rootCertificate = rootCertificate
    self.pcr3 = pcr3
    self.pcr8 = pcr8
  }
}
