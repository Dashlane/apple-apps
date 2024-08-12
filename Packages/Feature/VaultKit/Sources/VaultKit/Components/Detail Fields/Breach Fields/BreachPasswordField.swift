import CoreLocalization
import DesignSystem
import Foundation
import SwiftUI
import UIComponents
import UIDelight

public struct BreachPasswordField: DetailField {
  public let title: String

  @Binding
  var shouldReveal: Bool

  @Binding
  var text: String

  @Environment(\.detailFieldType)
  public var fiberFieldType

  @Binding
  var isFocused: Bool

  let isUserInteractionEnabled: Bool

  public init(
    title: String,
    text: Binding<String>,
    shouldReveal: Binding<Bool>,
    isFocused: Binding<Bool> = .constant(false),
    isUserInteractionEnabled: Bool = true
  ) {
    self.title = title
    self._text = text
    self._shouldReveal = shouldReveal
    self._isFocused = isFocused
    self.isUserInteractionEnabled = isUserInteractionEnabled
  }

  public var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.footnote)
          .foregroundColor(.ds.text.oddity.disabled)

        if text.isEmpty && !isFocused {
          Text(L10n.Core.dwmOnboardingFixBreachesDetailNoPassword)
            .font(.body)
            .foregroundColor(.ds.text.oddity.disabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .disabled(!isUserInteractionEnabled)
            .onTapGesture {
              self.isFocused = true
            }
        } else {
          textField
            .contentShape(Rectangle())
            .disabled(!isUserInteractionEnabled)
            .onTapGesture {
              self.isFocused = true
            }
        }
      }

      Toggle(isOn: $shouldReveal) {
        EmptyView()
      }.toggleStyle(RevealPasswordStyle(shouldReveal: $shouldReveal))
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(Color.ds.container.agnostic.neutral.supershy)
    .animation(.default, value: isFocused)
  }

  var textField: some View {
    PasswordField("", text: $text, isFocused: $isFocused)
      .passwordFieldSecure(!shouldReveal)
      .textContentType(.oneTimeCode)
      .passwordFieldMonospacedFont(true)
  }
}

struct RevealPasswordStyle: ToggleStyle {
  @Binding
  var shouldReveal: Bool

  private func image(for configuration: Self.Configuration) -> Image {
    return configuration.isOn ? Image.ds.action.hide.outlined : Image.ds.action.reveal.outlined
  }

  func makeBody(configuration: Self.Configuration) -> some View {
    image(for: configuration)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 24, height: 24)
      .fiberAccessibilityLabel(Text(configuration.isOn ? L10n.Core.kwHide : L10n.Core.kwReveal))
      .animation(nil, value: configuration.isOn)
      .foregroundColor(.ds.text.brand.quiet)
      .onTapGesture {
        self.shouldReveal.toggle()
      }
  }
}

struct BreachPasswordField_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      VStack {
        BreachPasswordField(
          title: "Title", text: .constant(""), shouldReveal: .constant(true),
          isFocused: .constant(false))
        BreachPasswordField(
          title: "Title", text: .constant(""), shouldReveal: .constant(false),
          isFocused: .constant(false))
        BreachPasswordField(
          title: "Title", text: .constant("test"), shouldReveal: .constant(true),
          isFocused: .constant(false))
        BreachPasswordField(
          title: "Title", text: .constant("test"), shouldReveal: .constant(false),
          isFocused: .constant(false))
      }
    }.previewLayout(.sizeThatFits)
  }
}
