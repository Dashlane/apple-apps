import Foundation

public class GenericError: Error {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }
}
