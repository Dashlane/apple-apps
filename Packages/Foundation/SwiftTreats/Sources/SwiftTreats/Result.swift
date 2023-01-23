import Foundation

extension Result {
    public var isFailure: Bool {
        if case .failure(_) = self {
            return true
        }
        return false
    }

    public var isSuccess: Bool {
        if case .success(_) = self {
            return true
        }
        return false
    }

                public func isFailure<E: Error & Equatable>(_ expectedError: E)  -> Bool {
        switch(self) {
        case let .failure(payload as E):
            return expectedError == payload
        default:
            return false;
        }
    }
}

public extension Result where Success == Void {
    static var success: Result {
        return Result.success(())
    }
}
