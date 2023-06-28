import SwiftUI
import CorePersonalData
import UIDelight
import VaultKit
import CoreLocalization

enum ButtonHovered {
    case copy
    case copyPassword
    case goToWebsite
    case reveal
    case hide

    var text: String {
        switch self {
        case .copy: return L10n.Localizable.safariCredentialRowTooltipCopyInfo
        case .copyPassword: return L10n.Localizable.kwCopyPasswordButton
        case .goToWebsite: return L10n.Localizable.kwGotoWebsite
        case .reveal: return L10n.Localizable.kwRevealButton
        case .hide: return CoreLocalization.L10n.Core.kwHide
        }
    }
}

struct CredentialRowView: View {
    
    let viewModel: CredentialRowViewModel
    
    @State private var isHovered: Bool = false

    @State private var buttonHover: ButtonHovered? = nil
    
    @Environment(\.toast)
    var toast
    
    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 16) {
                VaultItemIconView(model: viewModel.iconViewModel)
                accountInformation
            }
            Spacer()
            credentialActions.opacity(isHovered ? 1 : 0)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .onHover(perform: { hovering in
            isHovered = hovering
        })
    }
    
    @ViewBuilder
    var accountInformation: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(viewModel.item.displayTitle)
                    .foregroundColor(Color(NSColor.labelColor))
                    .font(Typography.smallHeader)
                    .lineLimit(1)
                viewModel.space.map {
                    UserSpaceIcon(space: $0, size: .small).equatable()
                }
            }
            Text(viewModel.item.displaySubtitle ?? viewModel.item.displayLogin)
                .foregroundColor(Color(NSColor.secondaryLabelColor))
                .font(Typography.caption2)
                .lineLimit(1)
        }
    }
    
    
    @ViewBuilder
    var credentialActions: some View {
        HStack(spacing: 8) {
            MenuView(label: copyLabel,
                     elements: [viewModel.copyActions]) { item in
                guard let action = item as? CopyCredentialAction else { return }
                viewModel.actionsPublisher.send(.copy(action))
                toast(action, for: viewModel.item)
            }
            .onHover(perform: { hovering in
                buttonHover = hovering ? .copy : nil
            })
            .overlayHover(buttonHover: buttonHover, hoverType: .copy, width: 75)
            goToWebsiteButton
                .onHover(perform: { hovering in
                    buttonHover = hovering ? .goToWebsite : nil
                })
                .overlayHover(buttonHover: buttonHover, hoverType: .goToWebsite, width: 100)
        }.frame(width: 75)
        .onTapGesture {
                    }
    }

    @ViewBuilder
    var copyLabel: some View {
        if viewModel.copyActions.isEmpty {
            Image(asset: Asset.copyInfo)
                .foregroundColor(Color(NSColor.disabledControlTextColor))
                .frame(width: 24, height: 24)
        } else {
            Image(asset: Asset.copyInfo)
                .foregroundColor(Color(asset: Asset.primaryHighlight))
                .frame(width: 24, height: 24)
                .hoverable()
        }
    }
    
    @ViewBuilder
    var goToWebsiteButton: some View {
        Button(action: {
            viewModel.actionsPublisher.send(.goToWebsite)
        }, label: {
            Image(asset: Asset.goToWebsite)
                .frame(width: 24, height: 24)
        })
                .buttonStyle(GoToWebsiteButtonStyle(canOpenWebsite: viewModel.canOpenWebsite))
    }
}

private struct GoToWebsiteButtonStyle: ButtonStyle {
    
    let canOpenWebsite: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        if canOpenWebsite {
            configuration.label
                .buttonStyle(LightButtonStyle())
                .foregroundColor(Color(asset: Asset.primaryHighlight))
                .hoverable()
        } else {
            configuration.label
                .buttonStyle(LightButtonStyle())
                .foregroundColor(Color(NSColor.disabledControlTextColor))
                .disabled(true)
        }
    }
}

struct CredentialRowView_Previews: PreviewProvider {
    
    static var previews: some View {
        PopoverPreviewScheme {
            CredentialRowView(viewModel: CredentialRowViewModel.mock(credential: PersonalDataMock.Credentials.netflix))
        }
    }
}

