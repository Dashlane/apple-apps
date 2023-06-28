import Foundation

public struct AuthTicket: Equatable {
    public let value: String

    public init(value: String) {
        self.value = value
    }
}
