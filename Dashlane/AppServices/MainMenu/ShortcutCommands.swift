import Foundation

protocol ShortcutCommand {
    var rawValue: String { get }
    init?(rawValue: String)
}

extension ShortcutCommand {
    init?(fromPropertyList: Any?) {
        guard let propertyList = fromPropertyList as? [String: String],
              let item = propertyList.first?.value else {
            return nil
        }
        guard let item = Self.init(rawValue: item) else {
            return nil
        }
        self = item
    }

    var propertyList: [String: String] {
        [UUID().uuidString: self.rawValue]
    }
}
