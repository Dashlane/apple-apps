import Foundation
#if !os(macOS)
import UIKit

public protocol MutatableBySubcript: AnyObject {
    
}

public extension MutatableBySubcript {
    subscript<V>(_ key: ReferenceWritableKeyPath<Self, V>) -> V where V: Equatable {
        get {
            self[keyPath: key]
        } set {
            guard newValue != self[keyPath: key] else {
                return
            }
            self[keyPath: key] = newValue
        }
    }
    
    subscript<V>(_ key: ReferenceWritableKeyPath<Self, V?>) -> V? where V: Equatable {
        get {
            self[keyPath: key]
        } set {
            guard newValue != self[keyPath: key] else {
                return
            }
            self[keyPath: key] = newValue
        }
    }
}


extension UIView: MutatableBySubcript {
    
}
#endif
