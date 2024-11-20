import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

struct RefreshableDetailField: DetailField {
  let title: String

  @Binding
  var shouldReveal: Bool

  @Binding
  var text: String

  var didTapRefresh: () -> Void

  init(
    title: String,
    text: Binding<String>,
    shouldReveal: Binding<Bool>,
    didTapRefresh: @escaping () -> Void
  ) {
    self.title = title
    self._text = text
    self._shouldReveal = shouldReveal
    self.didTapRefresh = didTapRefresh
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.footnote)
          .foregroundColor(.ds.text.inverse.standard)

        textField
          .disabled(true)
      }

      HStack(spacing: 25) {
        Button(
          action: { didTapRefresh() },
          label: {
            Image.ds.action.refresh.outlined
              .foregroundColor(.ds.text.brand.quiet)
          })

        Toggle(isOn: $shouldReveal) {
          EmptyView()
        }.toggleStyle(RevealPasswordStyle(shouldReveal: $shouldReveal))
      }

    }
  }

  @ViewBuilder
  var textField: some View {
    if shouldReveal == false {
      PasswordField("", text: $text)
        .textContentType(.oneTimeCode)
        .passwordFieldMonospacedFont(true)
    } else {
      PasswordText(text: text)
    }
  }
}

struct RefreshableDetailField_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      VStack {
        RefreshableDetailField(
          title: "Title", text: .constant("test"), shouldReveal: .constant(true), didTapRefresh: {})
        RefreshableDetailField(
          title: "Title", text: .constant("test"), shouldReveal: .constant(false), didTapRefresh: {}
        )
      }.background(.ds.background.alternate)
    }.previewLayout(.sizeThatFits)
  }
}
