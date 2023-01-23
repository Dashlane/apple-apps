import Foundation
import SwiftUI

@propertyWrapper
public struct BindingOrState<T>: DynamicProperty {
    private var valueBinding: Binding<T>?
    @State
    private var valueState: T
    
    public var projectedValue: Binding<T> {
        if let valueBinding = valueBinding {
            return valueBinding
        } else {
            return $valueState
        }
    }
    
    public var wrappedValue: T {
        get {
            if let valueBinding = valueBinding {
                return valueBinding.wrappedValue
            } else {
                return valueState
            }
        }
        nonmutating set {
            if let valueBinding = valueBinding {
                valueBinding.wrappedValue = newValue
            } else {
                valueState = newValue
            }
        }
    }
    
    public init(wrappedValue: T) {
        _valueState = .init(initialValue: wrappedValue)
    }
    
    public init(_ binding: Binding<T>) {
        _valueState = .init(initialValue: binding.wrappedValue)
        valueBinding = binding
    }
}
