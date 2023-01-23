import Foundation
import CoreSession
import CoreSync
import DashTypes

public extension SessionDirectory {
    func copyStore(for identifier: StoreIdentifier, from source: BuildTarget = .app, to target: BuildTarget) throws {
        let sourceURL = try storeURL(for: identifier, in: source)
        let destinationURL = try storeURL(for: identifier, in: target)
        
        if !fileManager.fileExists(atPath: sourceURL.path) {
            return
        }
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
    }
    
    func copyUnsharedStores(from source: BuildTarget = .app, to target: BuildTarget) throws {
        try StoreIdentifier.allCases
            .filter { !$0.sharedAcrossTargets }
            .forEach {
                try copyStore(for: $0, from: source, to: target)
            }
    }
}
