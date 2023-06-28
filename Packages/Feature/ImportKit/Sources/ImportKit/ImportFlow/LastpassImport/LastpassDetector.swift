import Foundation
import DashTypes

public protocol LastpassDetector {
    var isLastpassInstalled: Bool { get }
}

public protocol LastpassDetectorContainer {
    var lastpassDetector: LastpassDetector { get }
}

public extension LastpassDetector where Self == MockLastpassDetector {
    static var mock: MockLastpassDetector {
        MockLastpassDetector()
    }
}

public class MockLastpassDetector: LastpassDetector {
    public var isLastpassInstalled: Bool { false }
}
