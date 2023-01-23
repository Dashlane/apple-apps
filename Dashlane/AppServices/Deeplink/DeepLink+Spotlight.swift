import Foundation

private let componentsSeparator: Character = "/"

extension VaultDeepLinkIdentifier {
            var rawValue: String {
        return [component.rawValue, rawIdentifier].joined(separator: String(componentsSeparator))
    }
}
