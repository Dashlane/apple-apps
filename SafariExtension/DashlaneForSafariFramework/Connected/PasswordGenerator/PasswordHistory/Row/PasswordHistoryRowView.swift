import SwiftUI
import CorePersonalData
import UIDelight
import IconLibrary

struct PasswordHistoryRowView: View {

    var viewModel: PasswordHistoryRowViewModel

    @State private var isHovered: Bool = false

    @State private var buttonHover: ButtonHovered? = nil

    var revealOrHide: ButtonHovered {
        return shouldReveal ? .hide : .reveal
    }

    @AutoReverseState(defaultValue: false, autoReverseInterval: 10)
    var shouldReveal: Bool

    @Environment(\.toast)
    var toast

    let action: () -> Void

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()

    var body: some View {
        HStack {
            VStack(spacing: 1) {
                textField
                HStack(spacing: 4) {
                    subtitle
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(alignment: .leading)
            credentialActions.opacity(isHovered ? 1 : 0)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .onHover(perform: { hovering in
            isHovered = hovering
        })
        .dividerAdder(isActivated: isHovered)
    }

    var dateFormatted: Text {
        if let date = viewModel.generatedPassword.creationDatetime {
            return Text(Self.formatter.string(from: date))
        }
        else {
            return Text("")
        }
    }

    @ViewBuilder
    var credentialActions: some View {
        HStack(spacing: 8) {
            revealButton
            copyButton
        }.frame(width: 75)
        .onTapGesture {
                    }
    }

    @ViewBuilder
    var revealButton: some View {
        RowActionButton(enabled: true, action: {
            shouldReveal = !shouldReveal
        }, label: Image(asset: shouldReveal ? Asset.sensitiveHide : Asset.sensitiveReveal))
        .onHover(perform: { hovering in
            buttonHover = !hovering ? nil : revealOrHide
        })
        .overlayHover(buttonHover: buttonHover, hoverType: revealOrHide)
    }

    @ViewBuilder
    var copyButton: some View {
        RowActionButton(enabled: true, action: {
            viewModel.actionsPublisher.send(.copy)
            toast(L10n.Localizable.passwordGeneratorCopiedPassword, image: .ds.action.copy.outlined)
        }, label: Image(asset: Asset.copyInfo).foregroundColor(Color(asset: Asset.primaryHighlight)))
        .onHover(perform: { hovering in
            buttonHover = hovering ? .copyPassword : nil
        })
        .overlayHover(buttonHover: buttonHover, hoverType: .copyPassword, width: 110)
    }

    @ViewBuilder
    private var subtitle: some View {
        if let domain = viewModel.generatedPassword.domain?.displayDomain {
            let baseText: String = L10n.Localizable.generatedPasswordGeneratedOn(domain)

            PartlyModifiedText(text: baseText, toBeModified: domain) { text in
                text + Text(" ") + dateFormatted
                    .foregroundColor(Color(asset: Asset.secondaryHighlight))
            }
        } else {
            Text(L10n.Localizable.generatedPasswordGeneratedNoDomain)
                .foregroundColor(Color(asset: Asset.secondaryHighlight))
            + Text(" ")
            + dateFormatted
                .foregroundColor(Color(asset: Asset.secondaryHighlight))
        }
    }

    @ViewBuilder
    private var textField: some View {
        let password = viewModel.generatedPassword.password ?? ""

        ZStack {
            if shouldReveal {
                password.passwordColored(text: password)
            } else {
                Text(password as NSString, formatter: ObfuscatedCodeFormatter(max: 17))
                    .font(Font.system(.body, design: .monospaced))
                    .fiberAccessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(1)
        .id(shouldReveal)
    }
}
