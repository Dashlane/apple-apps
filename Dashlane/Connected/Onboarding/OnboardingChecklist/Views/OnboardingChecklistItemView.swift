import Foundation
import SwiftUI
import UIDelight
import NotificationCenter
import UIComponents
import DesignSystem

struct OnboardingChecklistItemView: View {

    enum DisplayMode {
        case suggestedBlock
        case fullDisplay
    }

    var showDetails = false

    var completed = false

    var hidden = false

    let action: OnboardingChecklistAction

    let ctaAction: (() -> Void)?

    let mode: DisplayMode

    init(showDetails: Bool = false,
         completed: Bool = false,
         hidden: Bool = false,
         action: OnboardingChecklistAction,
         ctaAction: (() -> Void)?,
         mode: DisplayMode = .fullDisplay) {
        self.showDetails = showDetails
        self.hidden = hidden
        self.completed = completed
        self.action = action
        self.ctaAction = ctaAction
        self.mode = mode
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 16) {
                if mode == .fullDisplay {
                    leadingView
                }
                trailingView
            }

            if mode == .fullDisplay {
                LottieView(action.animationAsset).frame(height: 175)
                    .hidden(!showDetails || completed)
            }

            Button(action.actionText, action: ctaAction ?? {})
                .frame(maxWidth: .infinity, alignment: .center)
                .buttonStyle(OnboardingButtonStyle())
                .hidden(!showDetails || completed)
                .fiberAccessibilityRemoveTraits(.isButton)
        }
        .padding(16)
        .background(.ds.container.agnostic.neutral.supershy)
        .cornerRadius(8.0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fiberAccessibilityElement(children: .ignore)
        .fiberAccessibilityLabel(Text(actionAccessibilityLabel))
        .fiberAccessibilityAddTraits(!completed ? [.isButton] : [])
        .fiberAccessibilityHint(!completed ? Text(action.accessibilityHint) : Text(""))
        .fiberAccessibilityAction(.default) {
                        guard !completed else { return }
            ctaAction?()
        }
    }

    var leadingView: some View {
        VStack(alignment: .center) {
            if completed {
                Image.ds.feedback.success.outlined
                    .foregroundColor(.ds.text.neutral.quiet)
                    .padding(.top, 3)
                    .padding(.leading, 2)
                    .fiberAccessibilityHidden(true)
            } else {
                Text(String(format: "%.2d", action.index))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.ds.text.neutral.quiet)
                    .frame(width: 24, height: 24, alignment: .center)
            }
        }
    }

    var trailingView: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                Text(action.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(completed ? .ds.text.neutral.quiet : .ds.text.neutral.catchy)
                    .fixedSize(horizontal: false, vertical: true)
                Text(action.caption)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.ds.text.neutral.standard)
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden(!showDetails || completed)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    var actionAccessibilityLabel: String {
        if completed {
            return action.accessibilityLabel(state: .completed)
        } else {
            return action.accessibilityLabel(state: .pending)
        }
    }
}

private extension OnboardingChecklistAction {

    enum State {
        case completed
        case pending
    }

    func accessibilityLabel(state: State) -> String {
        switch state {
        case .completed:
            return "\(accessibilityLabelPrefix). \(L10n.Localizable.onboardingChecklistAccessibilityDone). \(self.title)"
        case .pending:
            return "\(accessibilityLabelPrefix). \(L10n.Localizable.onboardingChecklistAccessibilityTodo). \(self.title). \(self.caption). \(self.actionText)."
        }
    }

    var accessibilityLabelPrefix: String {
        switch self.index {
        case 1:
            return L10n.Localizable.onboardingChecklistAccessibilityFirstCard
        case 2:
            return L10n.Localizable.onboardingChecklistAccessibilitySecondCard
        case 3:
            return L10n.Localizable.onboardingChecklistAccessibilityThirdAndLastCard
        default:
            assertionFailure("Unexpected index of an onboarding checklist item.")
            return L10n.Localizable.onboardingChecklistAccessibilityAnotherCard
        }
    }

    var accessibilityHint: String {
        switch self {
        case .activateAutofill:
            return L10n.Localizable.onboardingChecklistAccessibilityHintActivateAutofill
        case .addFirstPasswordsManually:
            return L10n.Localizable.onboardingChecklistAccessibilityHintAddPasswords
        case .importFromBrowser:
            return L10n.Localizable.onboardingChecklistAccessibilityHintImportFromBrowser
        case .fixBreachedAccounts:
            return L10n.Localizable.onboardingChecklistAccessibilityHintFixBreachedAccounts
        case .seeScanResult:
            return L10n.Localizable.onboardingChecklistAccessibilityHintSeeScanResult
        case .mobileToDesktop:
            return L10n.Localizable.onboardingChecklistAccessibilityHintM2W
        }
    }
}

private struct OnboardingButtonStyle: ButtonStyle {
    let backgroundColor: Color = .ds.container.expressive.brand.catchy.idle

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17.0, weight: .medium))
            .padding(16.0)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .background(configuration.isPressed ? backgroundColor.opacity(0.8) : backgroundColor)
            .foregroundColor(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(configuration.isPressed ? 1.02 : 1.0)
    }
}

struct OnboardingChecklistItemView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            Group {
                OnboardingChecklistItemView(action: .addFirstPasswordsManually, ctaAction: nil)
                OnboardingChecklistItemView(action: .activateAutofill, ctaAction: nil)
                OnboardingChecklistItemView(action: .mobileToDesktop, ctaAction: nil)
                OnboardingChecklistItemView(showDetails: true, action: .addFirstPasswordsManually, ctaAction: nil)
                OnboardingChecklistItemView(showDetails: true, action: .activateAutofill, ctaAction: nil)
                OnboardingChecklistItemView(showDetails: true, action: .mobileToDesktop, ctaAction: nil)
                OnboardingChecklistItemView(completed: true, action: .addFirstPasswordsManually, ctaAction: nil)
                OnboardingChecklistItemView(completed: true, action: .activateAutofill, ctaAction: nil)
                OnboardingChecklistItemView(completed: true, action: .mobileToDesktop, ctaAction: nil)
            }
        }
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}
