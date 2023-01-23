import SwiftUI
import UIDelight

struct ToggleDetailField: View {
    let title: String

    @Binding
    var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) { Text(title)
            .foregroundColor(Color(asset: FiberAsset.secondaryText))
            .font(.caption)
        }
    }
}

struct ToggleDetailField_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            ToggleDetailField(title: "field", isOn: .constant(false))
            ToggleDetailField(title: "field", isOn: .constant(true))
        }
    }
}
