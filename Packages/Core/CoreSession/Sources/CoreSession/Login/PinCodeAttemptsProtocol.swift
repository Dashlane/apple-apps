import Combine
import Foundation

public protocol PinCodeAttemptsProtocol: Sendable {
  var tooManyAttempts: Bool { get }
  var count: Int { get }
  func removeAll()
  func addNewAttempt()
}

public struct PinCodeAttemptsMock: PinCodeAttemptsProtocol {
  public var count: Int {
    settings.dates.count
  }

  final class Settings: @unchecked Sendable {
    var dates = [Date]()
  }

  var settings: Settings

  init() {
    self.settings = Settings()
  }

  public var tooManyAttempts: Bool {
    count >= 3
  }

  public func removeAll() {
    settings.dates.removeAll()
  }

  public func addNewAttempt() {
    settings.dates.append(Date())
  }

}

extension PinCodeAttemptsProtocol where Self == PinCodeAttemptsMock {
  public static var mock: PinCodeAttemptsMock {
    return PinCodeAttemptsMock()
  }
}
