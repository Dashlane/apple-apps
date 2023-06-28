import SwiftUI
import CoreLocalization

struct TextFieldRevealSecureContentButton: View {
    @Environment(\.textFieldOnRevealSecureValueAction) private var revealSecureValueAction
    private let reveal: Binding<Bool>

    init(reveal: Binding<Bool>) {
        self.reveal = reveal
    }

    var body: some View {
        Button(
            action: {
                reveal.wrappedValue.toggle()
                if reveal.wrappedValue {
                    revealSecureValueAction?()
                }
            },
            label: {
                Label {
                    Text(reveal.wrappedValue ? L10n.Core.kwHide : L10n.Core.kwReveal)
                } icon: {
                    (reveal.wrappedValue
                     ? Image.ds.action.hide.outlined
                     : .ds.action.reveal.outlined).resizable()
                }
                .labelStyle(.iconOnly)
            }
        )
    }
}

struct TextFieldRevealSecureContentButton_Previews: PreviewProvider {
    struct Preview: View {
        @State private var revealSecureContent = false
        @ScaledMetric private var dimension = 20

        var body: some View {
            VStack {
                TextFieldRevealSecureContentButton(reveal: $revealSecureContent)
                    .frame(width: dimension, height: dimension)
                    .background(.red.opacity(0.2))
                Text("reveals: \(String(describing: revealSecureContent))")
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}
