import Foundation
import SwiftUI
import UIDelight
import UIComponents

struct BreachPasswordField: DetailField {
    let title: String

    @Binding
    var shouldReveal: Bool

    @Binding
    var text: String

    @Environment(\.detailFieldType)
    var fiberFieldType
    
    @Binding
    var isFocused: Bool

    let isUserInteractionEnabled: Bool

    init(title: String,
         text: Binding<String>,
         shouldReveal: Binding<Bool>,
         isFocused: Binding<Bool> = .constant(false),
         isUserInteractionEnabled: Bool = true) {
        self.title = title
        self._text = text
        self._shouldReveal = shouldReveal
        self._isFocused = isFocused
        self.isUserInteractionEnabled = isUserInteractionEnabled
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote)
                    .foregroundColor(Color(asset: FiberAsset.grey01))

                if text.isEmpty && !isFocused {
                    Text(L10n.Localizable.dwmOnboardingFixBreachesDetailNoPassword)
                        .font(.body)
                        .foregroundColor(Color(asset: FiberAsset.grey01))
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
        .background(Color(asset: FiberAsset.cellBackground))
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
        return Image(asset: configuration.isOn ? FiberAsset.revealButtonSelected : FiberAsset.revealButton)
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        image(for: configuration)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .fiberAccessibilityLabel(Text(configuration.isOn ? L10n.Localizable.kwHide : L10n.Localizable.kwReveal))
            .animation(nil, value: configuration.isOn)
            .foregroundColor(Color(asset: FiberAsset.accentColor))
            .onTapGesture {
                self.shouldReveal.toggle()
        }
    }
}

struct BreachPasswordField_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            VStack {
                BreachPasswordField(title: "Title", text: .constant(""), shouldReveal: .constant(true), isFocused: .constant(false))
                BreachPasswordField(title: "Title", text: .constant(""), shouldReveal: .constant(false), isFocused: .constant(false))
                BreachPasswordField(title: "Title", text: .constant("test"), shouldReveal: .constant(true), isFocused: .constant(false))
                BreachPasswordField(title: "Title", text: .constant("test"), shouldReveal: .constant(false), isFocused: .constant(false))
            }.background(Color(asset: FiberAsset.neutralBackground))
        }.previewLayout(.sizeThatFits)
    }
}
