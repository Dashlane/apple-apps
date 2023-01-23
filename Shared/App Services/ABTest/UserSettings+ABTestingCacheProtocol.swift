import Foundation
import CoreFeature
import DashlaneAppKit
import CoreSettings

extension UserSettings: ABTestingCacheProtocol {
    public func storeTests(_ data: Data) {
        self[.abTestingCache] = data
    }
    
    public func storedTests() -> Data? {
        self[.abTestingCache]
    }
    
    public func deleteStoredTests() {
        self.deleteValue(for: .abTestingCache)
    }
}
