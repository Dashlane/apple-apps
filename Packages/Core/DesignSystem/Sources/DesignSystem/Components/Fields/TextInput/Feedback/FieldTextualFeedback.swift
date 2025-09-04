import SwiftUI

public struct FieldTextualFeedback: View {
  private let text: String

  public init(_ text: String) {
    self.text = text
  }

  public var body: some View {
    Text(verbatim: text)
      .foregroundStyle(
        .ds.text.overriding { @Sendable environment, color in
          if environment.style.mood == .brand {
            .ds.text.neutral.quiet
          } else {
            color
          }
        }
      )
      .textStyle(.body.helper.regular)
      .multilineTextAlignment(.leading)
      .fixedSize(horizontal: false, vertical: true)
      .transformEnvironment(\.style) { style in
        style = .init(mood: style.mood, intensity: .supershy, priority: style.priority)
      }
  }
}

#Preview {
  VStack {
    FieldTextualFeedback("Some additional information.")
    FieldTextualFeedback("Some additional information.")
      .style(.error)
    FieldTextualFeedback("Some additional information.")
      .style(.positive)
  }
}
