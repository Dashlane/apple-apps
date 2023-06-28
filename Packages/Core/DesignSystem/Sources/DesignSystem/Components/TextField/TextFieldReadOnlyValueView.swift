import SwiftUI
import UIDelight

struct TextFieldReadOnlyValueView: View {
    @Environment(\.isInputSecure) private var isSecure
    @Environment(\.textFieldIsSecureValueRevealed) private var isRevealed
    @Environment(\.textFieldValueColorHighlightingMode) private var colorHighlightingMode
    @Environment(\.textFieldFeedbackAppearance) private var feedbackAppearance
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ScaledMetric private var iconDimension = 12
    @ScaledMetric private var cornerRadius = 4
    @ScaledMetric private var trailingPadding = 4
    @ScaledMetric private var iconContainerDimension = 20

    private let value: String

    init(_ value: String) {
        self.value = value
    }

    var body: some View {
        Label {
            if useAttributedString {
                Text(attributedString)
            } else {
                Text(isSecure && !isRevealed
                     ? String(repeating: "•", count: value.count)
                     : value
                )
                .textStyle(
                    isSecure
                    ? .body.standard.monospace
                    : .body.standard.regular
                )
                .foregroundColor(.ds.text.neutral.catchy)
            }
        } icon: {
            iconView
        }
        .labelStyle(LeadingIconLabelStyle(spacing: 0))
        .padding(.trailing, trailingPadding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .foregroundColor(.ds.container.agnostic.neutral.standard)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(value))
    }

    private var iconView: some View {
        Image.ds.lock.filled
            .resizable()
            .frame(width: iconDimension, height: iconDimension)
            .foregroundColor(.ds.text.neutral.standard)
            .frame(width: iconContainerDimension, height: iconContainerDimension)
    }

    private var attributedString: AttributedString {
        switch colorHighlightingMode {
            case .password:
                return .passwordAttributedString(
                    from: value,
                    dynamicTypeSize: dynamicTypeSize
                )
            case .url:
                return .urlAttributedString(
                    from: value,
                    feedbackAppearance: feedbackAppearance,
                    dynamicTypeSize: dynamicTypeSize
                )
            default:
                return AttributedString()
        }
    }

    private var useAttributedString: Bool {
        guard colorHighlightingMode != nil else { return false }
        return (isSecure && isRevealed) || !isSecure
    }
}

struct TextFieldReadOnlyValueView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            TextFieldReadOnlyValueView("dashlane-challenge.company.com")
            TextFieldReadOnlyValueView("This is my content")
            TextFieldReadOnlyValueView("_")
                .secureInput()
            TextFieldReadOnlyValueView("_")
                .secureInput()
                .textFieldRevealSecureValue(true)
                .textFieldColorHighlightingMode(.password)
            TextFieldReadOnlyValueView("_")
                .textFieldColorHighlightingMode(.url)
            TextFieldReadOnlyValueView("_")
                .textFieldColorHighlightingMode(.url)
                .textFieldFeedbackAppearance(.error)
        }
    }
}
