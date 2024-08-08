import Foundation

public protocol AuthenticationCodeProducer {
  func authenticationCode(for data: Data) -> Data
}
