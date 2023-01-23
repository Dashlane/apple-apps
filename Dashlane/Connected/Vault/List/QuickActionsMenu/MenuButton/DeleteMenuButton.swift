import DesignSystem
import SwiftUI
import UIDelight

struct DeleteMenuButton: View {
    let action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action, label: buttonContent)
    }

    private func buttonContent() -> some View {
        HStack {
            Text(L10n.Localizable.deleteQuickAction)
            Image.ds.action.delete.outlined
        }
    }
}

struct DeleteMenuButton_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            DeleteMenuButton {

            }
        }
        .padding()
        .background(Color.ds.background.default)
        .previewLayout(.sizeThatFits)
    }
}
