import SwiftUI

public extension Button where Label == Text {
    init(action: @escaping () -> Void, title: String) {
        self.init(action: action, label: {
            Text(title)
        })
    }
}
