import Foundation
import CoreFeature
import DashlaneAppKit
import CoreSettings

extension AppSettings: ABTestingCacheProtocol {
    public func storeTests(_ data: Data) {
        abTestingCache = data
    }
    
    public func storedTests() -> Data? {
        abTestingCache
    }
    
    public func deleteStoredTests() {
        abTestingCache = nil
    }
}
