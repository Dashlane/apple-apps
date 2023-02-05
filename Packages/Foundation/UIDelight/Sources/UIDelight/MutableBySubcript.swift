import Foundation
#if !os(macOS)
import UIKit

public protocol MutableBySubcript: AnyObject {
    
}

public extension MutableBySubcript {
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


extension UIView: MutableBySubcript {
    
}
#endif
