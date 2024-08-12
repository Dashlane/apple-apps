import DashTypes
import Foundation

extension CryptoRawConfig {
  public init(
    fixedSalt: Data?,
    userMarker: CryptoEngineConfigHeader,
    teamSpaceMarker: CryptoEngineConfigHeader? = nil
  ) {
    let fixedSalt = fixedSalt
    if let teamSpaceMarker = teamSpaceMarker?.trimmingCharacters(in: .whitespaces),
      !teamSpaceMarker.isEmpty
    {
      self.init(fixedSalt: fixedSalt, marker: teamSpaceMarker)
    } else {
      let marker = userMarker.trimmingCharacters(in: .whitespaces)
      self.init(fixedSalt: fixedSalt, marker: marker)
    }
  }
}

public typealias CryptoEngineConfigHeader = String
