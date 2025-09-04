public protocol BackgroundServicesStateHandling: Sendable {
  func activate() async throws
  func deactivate() async throws
}

public final class BackgroundServicesStateHandlingMock: BackgroundServicesStateHandling, @unchecked
  Sendable
{
  init(isActive: Bool = true) {
    activeHistory = [isActive]
  }

  public var isActive: Bool {
    activeHistory.last ?? true
  }

  public private(set) var activeHistory: [Bool] = []

  public func activate() async throws {
    activeHistory.append(true)
  }
  public func deactivate() async throws {
    activeHistory.append(false)
  }
}

extension BackgroundServicesStateHandling where Self == BackgroundServicesStateHandlingMock {
  public static func mock(isActive: Bool = true) -> BackgroundServicesStateHandling {
    BackgroundServicesStateHandlingMock(isActive: isActive)
  }
}
