import DesignSystem
import Foundation
import SwiftUI
import SwiftUILottie
import UIComponents
import UIDelight

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

  init(
    showDetails: Bool = false,
    completed: Bool = false,
    hidden: Bool = false,
    action: OnboardingChecklistAction,
    ctaAction: (() -> Void)?,
    mode: DisplayMode = .fullDisplay
  ) {
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

      if mode == .fullDisplay && showDetails && !completed {
        LottieView(action.animationAsset).frame(height: 175)
      }

      if showDetails && !completed {
        Button(action.actionText, action: ctaAction ?? {})
          .frame(maxWidth: .infinity, alignment: .center)
          .buttonStyle(.designSystem(.titleOnly))
          .style(intensity: .catchy)
          .fiberAccessibilityRemoveTraits(.isButton)
      }
    }
    .padding(16)
    .background(.ds.container.agnostic.neutral.quiet)
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
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .padding(.top, 3)
          .padding(.leading, 2)
          .fiberAccessibilityHidden(true)
      } else {
        Text(String(format: "%.2d", action.index))
          .textStyle(.title.supporting.small)
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .frame(width: 24, height: 24, alignment: .center)
      }
    }
  }

  var trailingView: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading, spacing: 8) {
        Text(action.title)
          .textStyle(.title.section.medium)
          .foregroundStyle(completed ? Color.ds.text.neutral.quiet : Color.ds.text.neutral.catchy)
          .fixedSize(horizontal: false, vertical: true)
          .contentShape(
            .hoverEffect, RoundedRectangle(cornerRadius: 4, style: .continuous).inset(by: -5)
          )
          .hoverEffect(isEnabled: !showDetails && !completed)
        if showDetails && !completed {
          Text(action.caption)
            .textStyle(.body.reduced.regular)
            .foregroundStyle(Color.ds.text.neutral.quiet)
            .fixedSize(horizontal: false, vertical: true)
        }
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

extension OnboardingChecklistAction {

  fileprivate enum State {
    case completed
    case pending
  }

  fileprivate func accessibilityLabel(state: State) -> String {
    switch state {
    case .completed:
      return
        "\(accessibilityLabelPrefix). \(L10n.Localizable.onboardingChecklistAccessibilityDone). \(self.title)"
    case .pending:
      return
        "\(accessibilityLabelPrefix). \(L10n.Localizable.onboardingChecklistAccessibilityTodo). \(self.title). \(self.caption). \(self.actionText)."
    }
  }

  fileprivate var accessibilityLabelPrefix: String {
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

  fileprivate var accessibilityHint: String {
    switch self {
    case .activateAutofill:
      return L10n.Localizable.onboardingChecklistAccessibilityHintActivateAutofill
    case .addFirstPasswordsManually:
      return L10n.Localizable.onboardingChecklistAccessibilityHintAddPasswords
    case .mobileToDesktop:
      return L10n.Localizable.onboardingChecklistAccessibilityHintM2W
    }
  }
}

struct OnboardingChecklistItemView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      Group {
        OnboardingChecklistItemView(action: .addFirstPasswordsManually, ctaAction: nil)
        OnboardingChecklistItemView(action: .activateAutofill, ctaAction: nil)
        OnboardingChecklistItemView(action: .mobileToDesktop, ctaAction: nil)
        OnboardingChecklistItemView(
          showDetails: true, action: .addFirstPasswordsManually, ctaAction: nil)
        OnboardingChecklistItemView(showDetails: true, action: .activateAutofill, ctaAction: nil)
        OnboardingChecklistItemView(showDetails: true, action: .mobileToDesktop, ctaAction: nil)
        OnboardingChecklistItemView(
          completed: true, action: .addFirstPasswordsManually, ctaAction: nil)
        OnboardingChecklistItemView(completed: true, action: .activateAutofill, ctaAction: nil)
        OnboardingChecklistItemView(completed: true, action: .mobileToDesktop, ctaAction: nil)
      }
    }
    .background(Color.black)
    .previewLayout(.sizeThatFits)
  }
}
