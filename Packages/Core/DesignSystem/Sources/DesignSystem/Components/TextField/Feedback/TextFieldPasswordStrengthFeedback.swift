import SwiftUI
import CoreLocalization

public struct TextFieldPasswordStrengthFeedback: View {
    private static let colorfulColors: [Color] = [
        Color("pride1"),
        Color("pride2"),
        Color("pride3"),
        Color("pride4"),
        Color("pride5"),
        Color("pride6"),
        Color("pride7"),
        Color("pride8")
    ]

    public enum Strength: Int, CaseIterable {
        case weakest = 1
        case weak
        case acceptable
        case good
        case strong
    }

    @ScaledMetric private var height = 4
    @ScaledMetric private var topPadding = 4

    private let strength: Strength
    private let colorful: Bool

    public init(strength: Strength, colorful: Bool = false) {
        self.strength = strength
        self.colorful = colorful
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            strengthView
                .frame(height: height)
            Text(accessoryText)
                .textStyle(.body.helper.regular)
                .foregroundColor(Color.accessoryTextForegroundColor(for: strength, colorful: colorful))
                .frame(maxHeight: .infinity)
                .fixedSize(horizontal: false, vertical: true)
                .animation(.easeOut(duration: 0.25), value: strength)
        }
        .padding(.top, topPadding)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessoryText))
    }

    @ViewBuilder
    private var strengthView: some View {
        if colorful && strength == .strong {
            HStack(spacing: 0) {
                ForEach(Self.colorfulColors, id: \.self) { color in
                    color
                }
            }
            .clipShape(Capsule(style: .circular))
        } else {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule(style: .circular)
                        .foregroundColor(.ds.border.neutral.quiet.idle)
                    let fillPercentage = CGFloat(strength.rawValue) / CGFloat(Strength.allCases.count)
                    Capsule(style: .circular)
                        .foregroundColor(.strengthBarColor(for: strength))
                        .frame(width: (geometry.size.width * fillPercentage))
                        .animation(.spring(response: 0.35), value: strength)
                }
            }
        }
    }

    private var accessoryText: String {
        switch strength {
        case .weakest:
            return L10n.Core.passwordGeneratorStrengthVeryGuessabble
        case .weak:
            return L10n.Core.passwordGeneratorStrengthTooGuessable
        case .acceptable:
            return L10n.Core.passwordGeneratorStrengthSomewhatGuessable
        case .good:
            return L10n.Core.passwordGeneratorStrengthSafelyUnguessable
        case .strong:
            return L10n.Core.passwordGeneratorStrengthVeryUnguessable
        }
    }
}

private extension Color {
    static func strengthBarColor(for strength: TextFieldPasswordStrengthFeedback.Strength) -> Color {
        switch strength {
        case .weakest, .weak:
            return .ds.border.danger.standard.idle
        case .acceptable:
            return .ds.border.warning.standard.idle
        case .good, .strong:
            return .ds.border.positive.standard.idle
        }
    }

    static func accessoryTextForegroundColor(
        for strength: TextFieldPasswordStrengthFeedback.Strength?,
        colorful: Bool
    ) -> Color {
        switch strength {
        case .weakest, .weak:
            return .ds.text.danger.quiet
        case .acceptable:
            return .ds.text.warning.quiet
        case .good:
            return .ds.text.positive.quiet
        case .strong:
            if colorful { return .ds.text.neutral.quiet }
            return .ds.text.positive.quiet
        case .none:
            return .ds.text.neutral.quiet
        }
    }
}

struct TextFieldPasswordStrengthFeedback_Previews: PreviewProvider {

    struct Preview: View {
        @State private var strength = TextFieldPasswordStrengthFeedback.Strength.good

        var body: some View {
            VStack(spacing: 20) {
                VStack(spacing: 14) {
                    TextFieldPasswordStrengthFeedback(strength: strength)
                    DS.Button("Update") {
                        strength = TextFieldPasswordStrengthFeedback.Strength.allCases.randomElement()!
                    }
                }
                TextFieldPasswordStrengthFeedback(strength: .weakest)
                TextFieldPasswordStrengthFeedback(strength: .weak)
                TextFieldPasswordStrengthFeedback(strength: .acceptable)
                TextFieldPasswordStrengthFeedback(strength: .good)
                TextFieldPasswordStrengthFeedback(strength: .strong)
                TextFieldPasswordStrengthFeedback(strength: .strong, colorful: true)
            }
            .padding(.horizontal, 40)
        }
    }

    static var previews: some View {
        Preview()
    }
}
