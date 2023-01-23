import Foundation

public struct UnexpectedNilError<T>: Error {
    public let type: T.Type
}

extension Optional {
    public var unwrapped: Wrapped {
        get throws {
            switch self {
            case .none:
                throw UnexpectedNilError(type: Wrapped.self)
            case .some(let wrapped):
                return wrapped
            }
        }
    }
}
