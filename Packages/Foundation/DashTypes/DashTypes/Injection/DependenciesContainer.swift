public protocol DependenciesContainer {
    
}

public struct InjectedFactory<T> {
    public let factory: T
    public init(_ factory: T) {
        self.factory = factory
    }
}


