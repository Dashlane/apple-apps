import DesignSystem
import SwiftUI

struct PasswordHealthGauge<Label, CurrentValueLabel>: View where Label: View, CurrentValueLabel: View {

    @Binding
    private var value: Int?
    private let label: Label
    private let currentValueLabel: CurrentValueLabel

    @State
    private var currentValue: CGFloat = 0

    init(
        value: Binding<Int?>,
        @ViewBuilder label: () -> Label = { EmptyView() },
        @ViewBuilder currentValueLabel: () -> CurrentValueLabel = { EmptyView() }
    ) {
        self._value = value
        self.label = label()
        self.currentValueLabel = currentValueLabel()
    }

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Spacer()
                currentValueLabel

                    .padding(.top)
                Spacer()
                label
                    .padding(.bottom)
            }

            gauge
        }
        .fiberAccessibilityElement(children: .combine)
        .fiberAccessibilityLabel(Text(L10n.Localizable.passwordHealthModuleScore + " \(value ?? 0)"))
        .onChange(of: value) {
                        currentValue = (0.25 + (0.75 * CGFloat($0 ?? 0) / 100))
        }
    }

    private var gauge: some View {
        ZStack {
            Circle()
                .trim(from: 0.25, to: 1.0)
                .rotation(.degrees(45))
                .stroke(Color.ds.border.neutral.quiet.idle, style: .init(lineWidth: 12, lineCap: .round))

            if let value, value > 0 {
                Circle()
                    .trim(from: 0.25, to: currentValue)
                    .rotation(.degrees(45))
                    .stroke(tintColor, style: .init(lineWidth: 12, lineCap: .round))
                    .animation(.easeInOut(duration: 1), value: currentValue)
            }
        }
    }

    private var tintColor: Color {
        guard let value else {
            return .ds.border.neutral.quiet.idle
        }
        switch value {
        case 0..<50:
            return .ds.border.danger.standard.idle
        case 50..<80:
            return .ds.border.warning.standard.idle
        case 80...100:
            return .ds.border.positive.standard.idle
        default:
            return .ds.border.neutral.standard.idle
        }
    }
}

struct PasswordHealthGauge_Previews: PreviewProvider {
    static var previews: some View {
        PasswordHealthGauge(
            value: .constant(79),
            label: {
                Text(L10n.Localizable.widgetScoreSubtitle.uppercased())
                    .font(.footnote)
                    .foregroundColor(.ds.text.neutral.quiet)
            }, currentValueLabel: {
                Text("79")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.ds.text.neutral.catchy)
            }
        )
    }
}
