import Foundation

public enum BuildEnvironment {
        case appstore
        case debug
}

extension BuildEnvironment {
    public static var current: BuildEnvironment {
        #if DEBUG
        return .debug
        #else
        return .appstore
        #endif
    }
}

public extension BuildEnvironment {
    var isQA: Bool {
        return self == .appstore && Application.version().starts(with: "70.")
    }

    var isNightly: Bool {
        self == .appstore && Application.version().starts(with: "80.")
    }
}
