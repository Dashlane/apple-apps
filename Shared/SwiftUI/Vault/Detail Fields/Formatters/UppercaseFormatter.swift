import UIKit

class UppercaseFormatter: FieldFormatter {

    override func string(for obj: Any?) -> String? {
        guard let value = obj as? String else {
            return nil
        }

        return value.uppercased()
    }
}

extension Formatter {
    static var uppercase: UppercaseFormatter {
        return UppercaseFormatter()
    }
}
