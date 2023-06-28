import SwiftUI
import CoreLocalization

public struct DesignSystemTextField<ActionsContent: View, FeedbackAccessory: View>: View {
    public typealias Action = TextFieldAction

        @Environment(\.textFieldAppearance) private var appearance
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.style) private var style
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.textFieldFeedbackAppearance) private var feedbackAppearance

        private let label: String
    private let placeholder: String?
    private let actionsContent: ActionsContent
    private let feedbackAccessory: FeedbackAccessory

        @Binding private var text: String

        @ScaledMetric private var horizontalContentPadding = 16
    @ScaledMetric private var verticalContentPadding = 6

                                                                                                    public init(
        _ label: String,
        placeholder: String? = nil,
        text: Binding<String>,
        @ViewBuilder actions: () -> ActionsContent,
        @ViewBuilder feedback: () -> FeedbackAccessory
    ) {
        self.label = label
        self.placeholder = placeholder
        self.actionsContent = actions()
        self.feedbackAccessory = feedback()
        _text = text
    }

                                                                                        public init(
        _ label: String,
        placeholder: String? = nil,
        text: Binding<String>,
        @ViewBuilder actions: () -> ActionsContent
    ) where FeedbackAccessory == EmptyView {
        self.label = label
        self.placeholder = placeholder
        self.actionsContent = actions()
        self.feedbackAccessory = EmptyView()
        _text = text
    }

                                                                    public init(
        _ label: String,
        placeholder: String? = nil,
        text: Binding<String>,
        @ViewBuilder feedback: () -> FeedbackAccessory
    ) where ActionsContent == EmptyView {
        self.label = label
        self.placeholder = placeholder
        self.actionsContent = EmptyView()
        self.feedbackAccessory = feedback()
        _text = text
    }

                        public init(
        _ label: String,
        placeholder: String? = nil,
        text: Binding<String>
    ) where ActionsContent == EmptyView, FeedbackAccessory == EmptyView {
        self.label = label
        self.placeholder = placeholder
        self.actionsContent = EmptyView()
        self.feedbackAccessory = EmptyView()
        _text = text
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextFieldInputContainer(
                label,
                placeholder: placeholder,
                text: $text,
                actionsContent: { actionsContent }
            )
            TextFieldFeedbackContainer {
                feedbackAccessory
                    .padding(.horizontal, effectiveHorizontalContentPadding)
            }
        }
        #if targetEnvironment(macCatalyst)
        .tintColor(.tintColor(for: feedbackAppearance))
        #else
        .accentColor(.tintColor(for: feedbackAppearance))
        #endif
    }

    private var effectiveHorizontalContentPadding: Double {
        guard case .standalone = appearance else { return 0 }
        return horizontalContentPadding
    }
}

private extension Color {

    static func tintColor(for feedbackAppearance: TextFieldFeedbackAppearance?) -> Color {
        if let feedbackAppearance, case .error = feedbackAppearance {
            return .ds.text.danger.standard
        } else {
            return .ds.text.brand.standard
        }
    }
}

struct TextField_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldPreview()
            .padding()
            .ignoresSafeArea([.keyboard], edges: .bottom)
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    }
}
