import Foundation

class CodeObfuscationFormatter: FieldFormatter {
    let max: Int?

    public init(max: Int? = nil) {
        self.max = max
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func string(for obj: Any?) -> String? {
        guard let value = obj as? String else {
            return nil
        }
        guard !value.isEmpty else {
            return value
        }

        let count = max ?? value.count
        return String(repeating: "X", count: count)
    }
}
