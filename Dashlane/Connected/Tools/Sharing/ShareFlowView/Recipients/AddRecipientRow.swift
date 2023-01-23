import SwiftUI
import DesignSystem
import UIDelight

struct AddRecipientRow<Label: View>: View {
    let action: () -> Void

    @ViewBuilder
    let label: () -> Label

    var body: some View {
        HStack {
            label()
                .onTapWithFeedback(perform: action)
            RoundedButton(L10n.Localizable.kwAddButton, action: action)
                .controlSize(.mini)
                .style(mood: .neutral, intensity: .catchy)
        }.frame(maxWidth: .infinity, alignment: .leading)

    }
}

struct AddRecipientRow_Previews: PreviewProvider {
    static var previews: some View {
        AddRecipientRow {

        } label: {
            Text("Label")
        }
        .style(mood: .neutral, intensity: .catchy)

        AddRecipientRow {

        } label: {
            Text("Label")
        }
        .style(mood: .neutral, intensity: .quiet)
    }
}
