import SwiftUI

public extension EnvironmentValues {
    var detailFieldType: DetailFieldType {
        get {
            return self[FieldTypeEnvironmentKey.self]
        } set {
            self[FieldTypeEnvironmentKey.self] = newValue
        }
    }
}

private struct FieldTypeEnvironmentKey: EnvironmentKey {
    static var defaultValue: DetailFieldType = .login
}

public extension View {
    func fiberFieldType(_ type: DetailFieldType) -> some View {
        return self.environment(\.detailFieldType, type)
    }
}
