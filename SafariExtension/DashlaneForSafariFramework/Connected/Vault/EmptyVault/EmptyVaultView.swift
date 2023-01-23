import SwiftUI
import UIDelight

struct EmptyVaultView: View {
  
    let viewModel: EmptyVaultViewModelProtocol
  
    var body: some View {
        VStack(spacing: 32) {
            header
            steps
            Spacer()
            actionButton
        }
        .foregroundColor(Color(asset: Asset.secondaryHighlight))
        .padding(.top, 32)
        .padding(.bottom, 24)
        .padding(.horizontal, 24)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.Localizable.onboardingFirstPasswordTitle)
                .font(Typography.title)
                .foregroundColor(Color(asset: Asset.dashGreenCopy))
            Text(L10n.Localizable.onboardingFirstPasswordCaption)
                .font(Typography.body)
                .frame(minHeight: 40)
        }
    }
    
    private var steps: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(Step.allCases.indices) {
                element(for: Step.allCases[$0], number: $0 + 1)
            }
        }.frame(maxWidth: .infinity)
    }
    
    private func element(for step: Step, number: Int) -> some View {
        HStack(spacing: 8) {
            bullet(number: number)
            step.content
        }.frame(minHeight: 40)
    }
    
    private func bullet(number: Int) -> some View {
        Circle()
            .frame(width: 32, height: 32)
            .foregroundColor(Color(asset: Asset.dashGreenCopy))
            .overlay(
                Text("\(number)")
                    .font(Typography.smallHeader)
                    .foregroundColor(Color(asset: Asset.primaryInverted))
            )
    }
    
    private var actionButton: some View {
        Button(L10n.Localizable.onboardingFirstPasswordAction) {
            viewModel.dismissPopover()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .font(Typography.smallHeader)
        .buttonStyle(DashlaneDefaultButtonStyle(shouldTakeAllWidth: true))
    }
}

private extension EmptyVaultView {
    enum Step: CaseIterable {
        case openAnyWebsite
        case login
        case save
        
        var content: some View {
            switch self {
            case .openAnyWebsite:
                return MarkdownText(L10n.Localizable.onboardingFirstPasswordFirstStep)
                    .font(Typography.body)
            case .login:
                return MarkdownText(L10n.Localizable.onboardingFirstPasswordSecondStep)
                    .font(Typography.body)
            case .save:
                return MarkdownText(L10n.Localizable.onboardingFirstPasswordThirdStep)
                    .font(Typography.body)
            }
        }
    }
}

struct EmptyVaultView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverPreviewScheme(size: .popoverContent) {
            EmptyVaultView(viewModel: EmptyVaultViewModel.mock())
        }
    }
}
