import DesignSystem
import SwiftUI
import UIComponents

struct PasswordHealthGauge: View {
    let score: Int?

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Spacer()
                gaugeText
                    .font(DashlaneFont.custom(80, .bold).font)
                    .foregroundColor(.ds.text.neutral.catchy)
                    .padding(.top)
                Spacer()
                subtitle
                    .padding(.bottom)
            }

            gauge
        }
        .fiberAccessibilityElement(children: .ignore)
        .fiberAccessibilityAddTraits(.isStaticText)
        .fiberAccessibilityLabel(accessibilityLabel)
        .fiberAccessibilityHidden(score == nil) 
    }

    private var gaugeText: Text {
        if let score {
            return Text("\(score)")
        } else {
            return Text("--")
        }
    }

    private var subtitle: Text {
        Text(L10n.Localizable.widgetScoreSubtitle.uppercased())
            .font(.footnote)
            .foregroundColor(.ds.text.neutral.quiet)
    }

    private var accessibilityLabel: Text {
        guard let score else {
            return Text("")
        }

        return Text(L10n.Localizable.passwordHealthModuleScore + " \(score) " + L10n.Localizable.widgetScoreSubtitle)
    }

    private var pathValue: Double {
        (0.25 + (0.75 * CGFloat(score ?? 0) / 100))
    }

    private var gauge: some View {
        ZStack {
            Circle()
                .trim(from: 0.25, to: 1.0)
                .rotation(.degrees(45))
                .stroke(Color.ds.border.neutral.quiet.idle, style: .init(lineWidth: 12, lineCap: .round))

            if let score, score > 0 {
                Circle()
                    .trim(from: 0.25, to: pathValue)
                    .rotation(.degrees(45))
                    .stroke(tintColor, style: .init(lineWidth: 12, lineCap: .round))
                    .animation(.easeInOut(duration: 1), value: score)
            }
        }
    }

    private var tintColor: Color {
        guard let score else {
            return .ds.border.neutral.quiet.idle
        }
        switch score {
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
        PasswordHealthGauge(score: 79)
        PasswordHealthGauge(score: nil)
            .previewDisplayName("No Score")
    }
}
