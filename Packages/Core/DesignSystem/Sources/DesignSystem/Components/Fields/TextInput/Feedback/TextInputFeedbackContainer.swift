import SwiftUI

struct TextInputFeedbackContainer<Content: View>: View {
  @ScaledMetric private var verticalPadding = 4

  private let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    content
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.vertical, verticalPadding)
  }
}

struct TextInputFeedbackContainer_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      TextInputFeedbackContainer {
        FieldTextualFeedback("Some additional information.")
      }

      TextInputFeedbackContainer {
        TextInputPasswordStrengthFeedback(strength: .weak)
      }
    }
    .padding(.horizontal, 20)
  }
}
