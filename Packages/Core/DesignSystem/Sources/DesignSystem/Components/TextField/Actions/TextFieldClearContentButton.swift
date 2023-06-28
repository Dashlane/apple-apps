import SwiftUI
import CoreLocalization

public struct TextFieldClearContentButton: View {
    @State private var displayButton: Bool
    private let text: Binding<String>

    public init(text: Binding<String>) {
        self.text = text
        _displayButton = .init(initialValue: !text.wrappedValue.isEmpty)
    }

    public var body: some View {
        ZStack {
            if displayButton {
                Button(
                    action: { text.wrappedValue = "" },
                    label: {
                        Label {
                            Text(L10n.Core.accessibilityClearText)
                        } icon: {
                            Image.ds.action.clearContent.filled.resizable()
                        }
                        .labelStyle(.iconOnly)
                    }
                )
                .accessibilityLabel(Text(L10n.Core.accessibilityClearText))
            }
        }
        .onChange(of: text.wrappedValue) { newValue in
            displayButton(!newValue.isEmpty)
        }
    }

    private func displayButton(_ display: Bool) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            displayButton = display
        }
    }
}

struct TextFieldClearContentButton_Previews: PreviewProvider {
    struct Preview: View {
        @State private var text = "Hello World!"
        @ScaledMetric private var dimension = 20

        var body: some View {
            VStack {
                TextFieldClearContentButton(text: $text)
                    .frame(width: dimension, height: dimension)
                    .background(.red.opacity(0.2))

                Text(text)
            }
        }
    }
    static var previews: some View {
        Preview()
    }
}
