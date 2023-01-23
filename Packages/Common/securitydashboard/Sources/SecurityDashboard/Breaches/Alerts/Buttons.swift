import Foundation

public struct Buttons {
    public let left: [AlertButton]
    public let right: [AlertButton]

    public init(left: AlertButton?, right: AlertButton?) {
        self.left = [left].compactMap({ $0 })
        self.right = [right].compactMap({ $0 })
    }

    public init(left: [AlertButton], right: [AlertButton]) {
        self.left = left
        self.right = right
    }
}
