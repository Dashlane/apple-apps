#if canImport(UIKit)
  import Foundation
  import UIKit

  public protocol MutatableBySubcript: AnyObject {

  }

  extension MutatableBySubcript {
    public subscript<V>(_ key: ReferenceWritableKeyPath<Self, V>) -> V where V: Equatable {
      get {
        self[keyPath: key]
      }
      set {
        guard newValue != self[keyPath: key] else {
          return
        }
        self[keyPath: key] = newValue
      }
    }

    public subscript<V>(_ key: ReferenceWritableKeyPath<Self, V?>) -> V? where V: Equatable {
      get {
        self[keyPath: key]
      }
      set {
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
