import Foundation

extension Data {
  public static func makeRandomCredentialIdentifier() -> Data {
    let defaultIDSize = 16
    return Data((0..<defaultIDSize).map { _ in UInt8.random(in: UInt8.min...UInt8.max) })
  }
}
