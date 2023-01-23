import SwiftUI

@MainActor
public class GlobalEnvironmentValues {
    fileprivate static let shared: GlobalEnvironmentValues = .init()
    private let defaultEnvironmentValues = EnvironmentValues()

    private init() {

    }

    @Published
    var environments: [EnvironmentValues] = []

    public subscript<Key: EnvironmentKey>(_ key: Key.Type) -> Key.Value {
        get {
            guard let value = environments.first else {
                return defaultEnvironmentValues[key]
            }

            return value[key]
        } set {
            guard !environments.isEmpty else {
                return
            }

            environments[0][key] = newValue
        }
    }


    private func pushNewEnvironment() {
        let previous = environments.first ?? defaultEnvironmentValues
        environments.insert(previous, at: 0)
    }

    private func popActiveEnvironment() {
        environments.removeFirst()
    }
}

extension GlobalEnvironmentValues {
                public static func pushNewEnvironment() -> GlobalEnvironmentValues {
        shared.pushNewEnvironment()
        return shared
    }

                public static func popActiveEnvironment() {
        shared.popActiveEnvironment()
    }
}

@propertyWrapper
public struct GlobalEnvironment<Value>: DynamicProperty {
    @MainActor
    class EnvironmentObserver<Value>: ObservableObject {
        @Published
        var value: Value

        init(keyPath: KeyPath<GlobalEnvironmentValues, Value>) {
            let globalEnvironment = GlobalEnvironmentValues.shared
            self.value = globalEnvironment[keyPath: keyPath]
            
            let currentEnvCount = globalEnvironment.environments.count

            globalEnvironment
                .$environments
                .map(\.count)
                .filter {
                                                            $0 == currentEnvCount
                }
                .receive(on: DispatchQueue.main)
                .map { _ in
                    globalEnvironment[keyPath: keyPath]
                }.assign(to: &$value)
        }
    }

    @StateObject
    var environmentObserver: EnvironmentObserver<Value>

    public var wrappedValue: Value {
        return environmentObserver.value
    }

    public init(_ keyPath: KeyPath<GlobalEnvironmentValues, Value>) {
        _environmentObserver = StateObject(wrappedValue: .init(keyPath: keyPath))
    }
}
