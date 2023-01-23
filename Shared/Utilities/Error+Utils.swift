import Foundation

extension Error {
    var isConnectionError: Bool {
        switch self {
        case let urlError as URLError where urlError.code == .notConnectedToInternet:
            return true
        case let urlError as URLError where urlError.code == .networkConnectionLost:
            return true
        case let urlError as URLError where urlError.code == .cannotConnectToHost:
            return true
        case let urlError as URLError where urlError.code == .timedOut:
            return true
        default:
            return false
        }
    }
}
