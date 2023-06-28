import DesignSystem
import SwiftUI

public struct ActionDetailField: DetailField {
    let title: String
    let actionTitle: String
    let action: () -> Void

    public init(title: String, actionTitle: String, action: @escaping () -> Void) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        Button(action: action, title: actionTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accentColor(.ds.text.brand.standard)
            .labeled(title)
    }
}

struct ActionDetailField_Previews: PreviewProvider {
    static var previews: some View {
        ActionDetailField(title: "Action", actionTitle: "Do something") {

        }
    }
}
