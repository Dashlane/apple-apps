#if canImport(UIKit)
import UIKit

public class UppercaseFormatter: FieldFormatter {

    public override func string(for obj: Any?) -> String? {
        guard let value = obj as? String else {
            return nil
        }

        return value.uppercased()
    }
}

extension Formatter {
    public static var uppercase: UppercaseFormatter {
        return UppercaseFormatter()
    }
}
#endif
