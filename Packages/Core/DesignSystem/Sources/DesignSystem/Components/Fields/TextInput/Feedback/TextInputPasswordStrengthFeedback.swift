import CoreLocalization
import SwiftUI

#if canImport(UIKit)
  import UIKit
#endif

public struct TextInputPasswordStrengthFeedback: View {
  private static let colorfulColors: [Color] = [
    Color("pride1"),
    Color("pride2"),
    Color("pride3"),
    Color("pride4"),
    Color("pride5"),
    Color("pride6"),
    Color("pride7"),
    Color("pride8"),
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
      Text(accessoryText(for: strength))
        .textStyle(.body.helper.regular)
        .foregroundColor(Color.accessoryTextForegroundColor(for: strength, colorful: colorful))
        .frame(maxHeight: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .animation(.easeOut(duration: 0.25), value: strength)
    }
    .padding(.top, topPadding)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Text(accessoryText(for: strength)))
    .onChange(of: strength) { newStrength in
      makeAccessibilityAnnouncement(for: newStrength)
    }
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
      ZStack(alignment: .leading) {
        Capsule(style: .circular)
          .foregroundColor(.ds.border.neutral.quiet.idle)
        let fillPercentage = CGFloat(strength.rawValue) / CGFloat(Strength.allCases.count)
        ProgressBarLayout(progress: fillPercentage) {
          Capsule(style: .circular)
            .foregroundColor(.strengthBarColor(for: strength))
        }
      }
      .animation(.spring(response: 0.35), value: strength)
    }
  }

  private func accessoryText(for strength: Strength) -> String {
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

  private func makeAccessibilityAnnouncement(for strength: Strength) {
    #if canImport(UIKit)
      UIAccessibility.post(
        notification: .announcement,
        argument: accessoryText(for: strength)
      )
    #endif
  }
}

struct ProgressBarLayout: Layout {
  let progress: Double

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    return proposal.replacingUnspecifiedDimensions()
  }

  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
  ) {
    assert(subviews.count == 1)
    subviews[0].place(
      at: .init(x: bounds.minX, y: bounds.midY), anchor: .leading,
      proposal: .init(width: progress * bounds.width, height: bounds.height))
  }
}

extension Color {
  fileprivate static func strengthBarColor(for strength: TextInputPasswordStrengthFeedback.Strength)
    -> Color
  {
    switch strength {
    case .weakest, .weak:
      return .ds.border.danger.standard.idle
    case .acceptable:
      return .ds.border.warning.standard.idle
    case .good, .strong:
      return .ds.border.positive.standard.idle
    }
  }

  fileprivate static func accessoryTextForegroundColor(
    for strength: TextInputPasswordStrengthFeedback.Strength?,
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

struct TextInputPasswordStrengthFeedback_Previews: PreviewProvider {

  struct Preview: View {
    @State private var strength = TextInputPasswordStrengthFeedback.Strength.good

    var body: some View {
      VStack(spacing: 20) {
        VStack(spacing: 14) {
          TextInputPasswordStrengthFeedback(strength: strength)
          Button("Update") {
            strength = TextInputPasswordStrengthFeedback.Strength.allCases.randomElement()!
          }
          .buttonStyle(.designSystem(.titleOnly))
        }
        TextInputPasswordStrengthFeedback(strength: .weakest)
        TextInputPasswordStrengthFeedback(strength: .weak)
        TextInputPasswordStrengthFeedback(strength: .acceptable)
        TextInputPasswordStrengthFeedback(strength: .good)
        TextInputPasswordStrengthFeedback(strength: .strong)
        TextInputPasswordStrengthFeedback(strength: .strong, colorful: true)
      }
      .padding(.horizontal, 40)
    }
  }

  static var previews: some View {
    Preview()
  }
}
