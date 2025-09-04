import CoreTypes
import Foundation

public protocol LastpassDetector {
  var isLastpassInstalled: Bool { get }
}

public protocol LastpassDetectorContainer {
  var lastpassDetector: LastpassDetector { get }
}

extension LastpassDetector where Self == MockLastpassDetector {
  public static var mock: MockLastpassDetector {
    MockLastpassDetector()
  }
}

public class MockLastpassDetector: LastpassDetector {
  public var isLastpassInstalled: Bool { false }
}
