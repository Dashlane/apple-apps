import Foundation

public protocol TrayAlertProtocol: AlertProtocol {
    var timestamp: String? { get }
    var date: AlertSection? { get }
}

public struct TrayAlertContainer: Equatable {
    public let alert: TrayAlertProtocol

    public init(_ alert: TrayAlertProtocol) {
        self.alert = alert
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.alert.breach.id == rhs.alert.breach.id
    }
}
