import SwiftUI
import DesignSystem

struct InfoboxView: View {
    enum ViewConfiguration: String, CaseIterable {
        case moodsLight
        case moodsDark
        case standardConfigurations
        case overrides
        case smallestDynamicTypeClass
        case standardDynamicTypeClass
        case largestDynamicTypeClass
    }

    var viewConfiguration: ViewConfiguration? {
        guard let configuration = ProcessInfo.processInfo.environment["infoboxConfiguration"] else { return nil }
        return ViewConfiguration(rawValue: configuration)
    }

    var body: some View {
        ScrollView {
            switch viewConfiguration {
            case .moodsLight:
                moodsPreview
                    .environment(\.colorScheme, .light)
            case .moodsDark:
                moodsPreview
                    .environment(\.colorScheme, .dark)
                    .background(.black)
            case .standardConfigurations:
                VStack {
                                        ForEach([ControlSize.small, .regular, .large], id: \.self) { controlSize in
                        Infobox(title: "Title")
                            .controlSize(controlSize)
                    }
                    Infobox(title: "Title") {
                        Button("Primary 1") {}
                    }
                    Infobox(title: "Title") {
                        Button("Primary 2") {}
                        Button("Secondary 1") {}
                    }

                                        ForEach([ControlSize.regular, .large], id: \.self) { controlSize in
                        Infobox(
                            title: "Title",
                            description: "Description"
                        )
                        .controlSize(controlSize)
                    }

                                        Infobox(title: "Title") {
                        Button("Primary 3") {}
                        Button("Secondary 2") {}
                    }

                                        Infobox(title: "Title", description: "Description") {
                        Button("Primary 4") {}
                        Button("Secondary 3") {}
                    }
                }
                .padding()
            case .overrides:
                Infobox(title: "Title",
                        description: "Description") {
                    Button("Primary 5") {}
                }
                .infoboxButtonStyle(.standaloneSecondaryButton)
                .padding()
            case .smallestDynamicTypeClass:
                dynamicTypePreview
                    .environment(\.sizeCategory, .extraSmall)
            case .standardDynamicTypeClass:
                dynamicTypePreview
            case .largestDynamicTypeClass:
                dynamicTypePreview
                    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
            case .none:
                EmptyView()
            }
        }
    }

    private var moodsPreview: some View {
        VStack {
            ForEach(Mood.allCases) { mood in
                Infobox(title: "Title \(mood)",
                        description: "Description \(mood)") {
                    Button(action: {}, title: "Primary \(mood)")
                    Button(action: {}, title: "Secondary \(mood)")

                }
                        .style(mood: mood)
            }
        }
        .padding()
    }

    private var dynamicTypePreview: some View {
        VStack {
            Infobox(title: "A precious additional information",
                    description: "More details about what it impacts and what to do about it.") {
                Button("Primary - a very long title") {}
                Button("Secondary - a very long title") {}
            }
            .style(mood: .danger)
        }
        .padding()
    }
}

struct InfoboxView_Previews: PreviewProvider {
    static var previews: some View {
        InfoboxView()
    }
}
