import SwiftUI

public struct ToggleText<S: StringProtocol>: View {
    let title: S

    public var body: some View {
        Text(title)
            .textStyle(.body.standard.regular)
    }

    init(_ title: S) {
        self.title = title
    }
}

public struct DesignSystemToggle<Label: View>: View {
    @ScaledMetric private var spacing = 16

    private let label: Label
    private var isOn: Binding<Bool>

                        public init(isOn: Binding<Bool>, @ViewBuilder label: () -> Label) {
        self.isOn = isOn
        self.label = label()
    }

                        public init<S: StringProtocol>(_ title: S, isOn: Binding<Bool>) where Label == ToggleText<S> {
        self.label = ToggleText(title)
        self.isOn = isOn
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: spacing) {
            label
                .foregroundColor(.ds.text.neutral.standard)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .alignmentGuide(.firstTextBaseline) { context in
                    let remainingLineHeight = (context.height - context[.lastTextBaseline])
                    let lineHeight = context[.firstTextBaseline] + remainingLineHeight
                    let lineVerticalCenter = lineHeight / 2
                    return lineVerticalCenter
                }
            Toggle(isOn: isOn) {
                EmptyView()
            }
            .labelsHidden()
            .tint(.ds.container.expressive.brand.catchy.idle)
            .fixedSize()
            .alignmentGuide(.firstTextBaseline) { context in
                context[VerticalAlignment.center]
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct DesignSystemToggle_Previews: PreviewProvider {
    private struct Preview: View {
        @State private var toggle1 = true
        @State private var toggle2 = true

        var body: some View {
            List {
                DS.Toggle("This is an option.", isOn: $toggle1)
                DS.Toggle(
                    "This is a very long option that will spawn on multilines.",
                    isOn: $toggle2
                )
                DS.Toggle(
                    "This is an extreme option that will spawn on 3 lines.\nShould be exceptional.",
                    isOn: $toggle2
                )
            }
        }
    }
    static var previews: some View {
        Preview()
    }
}
