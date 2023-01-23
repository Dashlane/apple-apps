import SwiftUI
import UIDelight
import CoreLocalization

public struct Infobox: View {

    @ScaledMetric
    private var contentScale = 100

    @ScaledMetric
    private var containerCornerRadius = 4

    @Environment(\.controlSize)
    private var controlSize

    @Environment(\.infoboxButtonSectionConfiguration)
    private var buttonSectionConfiguration: ButtonSectionConfiguration

    @Environment(\.style)
    private var style

    var title: String
    var description: String? = nil
    let firstButton: Button<Text>?
    let secondButton: Button<Text>?
    
    public var body: some View {
        VStack(spacing: 16) {
            Label {
                VStack(alignment: .leading, spacing: 4) {
                    titleView
                    descriptionView
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } icon: {
                infoIconView
            }
            .labelStyle(.titleAndIcon)
            .fiberAccessibilityElement(children: .combine)
            .fiberAccessibilityLabel(Text("\(L10n.Core.accessibilityInfoSection): \(title), \(description ?? "")"))
            
            buttonSection
                .frame(alignment: .trailing)
        }
        .padding(containerPadding)
        .background(
            RoundedRectangle(cornerRadius: containerCornerRadius, style: .continuous)
                .fill(containerBackgroundColor)
        )
        .controlSize(effectiveControlSize)
    }
    
    private var infoIconView: some View {
        Image.ds.feedback.info.outlined
            .renderingMode(.template)
            .resizable()
            .foregroundColor(contentColor)
            .frame(width: iconSize.width, height: iconSize.height)
            .accessibilityHidden(true)
    }

    private var titleView: some View {
        Text(title)
            .font(titleFont)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(contentColor)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = description {
            Text(description)
                .font(descriptionFont)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(contentColor)
        }
    }
    
    @ViewBuilder
    private var buttonSection: some View {
        if firstButton != nil {
            AdaptiveHStack(spacing: 8) { typeSize in
                if typeSize.isAccessibilitySize {
                    primaryButton
                    secondaryButton
                } else {
                    Spacer()
                    secondaryButton
                    primaryButton
                }
            }
        }
    }

    private var primaryButton: some View {
        firstButton
            .buttonStyle(
                InfoboxButtonStyle(role: buttonSectionConfiguration == .standaloneSecondaryButton ? .secondary : .primary)
            )
    }

    @ViewBuilder
    private var secondaryButton: some View {
        if buttonSectionConfiguration.shouldShowTwoButtons {
            secondButton
                .buttonStyle(InfoboxButtonStyle(role: .secondary))
        }
    }

    private var effectiveContentScale: Double {
        contentScale / 100
    }

    private var effectiveControlSize: ControlSize {
                guard firstButton == nil else { return .large }

                if description != nil && [.mini, .small].contains(controlSize) {
            return .regular
        }

        return controlSize
    }
}

struct InfoBox_Previews: PreviewProvider {
    static var previews: some View {
                                VStack {
            ForEach(Mood.allCases) { mood in
                Infobox(title: "Title",
                        description: "Description") {
                    Button("Primary Button") {}
                    Button("Secondary Button") {}
                }
                .style(mood: mood)
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Mood variations")

                                VStack {
                        Infobox(title: "A precious bit of information")
                .controlSize(.small)
                .style(mood: .brand)
                        Infobox(
                title: "A precious bit of information",
                description: "More info about the impact and what to do about it."
            )
            .style(mood: .brand)
                        Infobox(
                title: "A precious bit of information",
                description: "More info about the impact and what to do about it."
            )
            .controlSize(.large)
            .style(mood: .brand)
                        Infobox(
                title: "A precious bit of information",
                description: "More info about the impact and what to do about it."
            ) {
                Button("Primary Button") {}
                Button("Secondary Button") {}
            }
            .style(mood: .brand)
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("SizeClass variations")

                                VStack {
                        ForEach([ControlSize.small, .regular], id: \.self) { controlSize in
                Infobox(title: "Title")
                    .controlSize(controlSize)
                    .style(mood: .brand)
            }
            Infobox(title: "Title") {
                Button("Primary Button") {}
            }
            .style(mood: .brand)
            Infobox(title: "Title") {
                Button("Primary Button") {}
                Button("Secondary Button") {}
            }
            .style(mood: .brand)
            
                        ForEach([ControlSize.regular, .large], id: \.self) { controlSize in
                Infobox(title: "Title", description: "Description")
                    .controlSize(controlSize)
                    .style(mood: .brand)
            }

                        Infobox(title: "Title") {
                Button("Primary Button") {}
                Button("Secondary Button") {}
            }
            .style(mood: .brand)

                        Infobox(title: "Title", description: "Description") {
                Button("Primary Button") {}
                Button("Secondary Button") {}
            }
            .style(mood: .brand)
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Standard configurations")

                                VStack {
            Infobox(title: "Title",
                    description: "Description") {
                Button("Primary Button") {}
            }
            .infoboxButtonStyle(.standaloneSecondaryButton)
            .style(mood: .brand)
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Button style overrides")

                                VStack {
            Infobox(title: "Title", description: "Description") {
                if true {
                    Button("Primary Action") {}
                }
            }
            .style(mood: .brand)

            Infobox(title: "My awesome title!") {
                if true {
                    Button("Optionally Primary Action") {}
                }
                Button("Secondary or Primary Action") {}
            }
            .style(mood: .brand)
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Conditional buttons")
    }
}

public extension Infobox {
    private var contentColor: Color {
        switch style.mood {
        case .neutral:
            return .ds.text.neutral.standard
        case .brand:
            return .ds.text.brand.standard
        case .warning:
            return .ds.text.warning.standard
        case .danger:
            return .ds.text.danger.standard
        case .positive:
            return .ds.text.positive.standard
        }
    }
    
    private var containerBackgroundColor: Color {
        switch style.mood {
        case .neutral:
            return .ds.container.expressive.neutral.quiet.idle
        case .brand:
            return .ds.container.expressive.brand.quiet.idle
        case .warning:
            return .ds.container.expressive.warning.quiet.idle
        case .danger:
            return .ds.container.expressive.danger.quiet.idle
        case .positive:
            return .ds.container.expressive.positive.quiet.idle
        }
    }
}

extension Infobox {
    private var titleFont: Font {
        switch effectiveControlSize {
        case .mini, .small:
            return .system(.footnote).weight(.medium)
        case .large:
            return .system(.body).weight(.semibold)
        case .regular:
            fallthrough
        @unknown default:
            return .system(.subheadline).weight(.semibold)
        }
    }

    private var descriptionFont: Font {
        switch effectiveControlSize {
        case .large:
            return .system(.subheadline)
        default:
            return .system(.footnote)
        }
    }
}

extension Infobox {
    private var containerPadding: Double {
        switch effectiveControlSize {
        case .large:
            return 16
        default:
            return 12
        }
    }

    private var iconSize: CGSize {
        let size: CGSize

        switch effectiveControlSize {
        case .mini, .small:
            size = CGSize(width: 10, height: 10)
        case .large:
            size = CGSize(width: 16, height: 16)
        case .regular:
            fallthrough
        @unknown default:
            size = CGSize(width: 13, height: 13)
        }

        return size.applying(.init(scaleX: effectiveContentScale, y: effectiveContentScale))
    }
}

public extension Infobox {
    enum ButtonSectionConfiguration {
        case secondaryAndPrimary
        case standaloneSecondaryButton
        
        var shouldShowTwoButtons: Bool {
            switch self {
            case .secondaryAndPrimary:
                return true
            case .standaloneSecondaryButton:
                return false
            }
        }
    }
}
