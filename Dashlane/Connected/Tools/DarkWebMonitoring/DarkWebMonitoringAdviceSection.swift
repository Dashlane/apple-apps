import DesignSystem
import Foundation
import SwiftUI
import UIDelight

enum DarkWebMonitoringAdvice {
  case changePassword((() -> Void)?)
  case savedNewPassword((() -> Void)?, (() -> Void)?)

  var sectionTitle: String? {
    switch self {
    case .changePassword: return L10n.Localizable.dwmOurAdviceTitle
    case .savedNewPassword: return nil
    }
  }

  var title: String? {
    switch self {
    case .changePassword: return nil
    case .savedNewPassword: return L10n.Localizable.dwmAdviceSectionSavePasswordTitle
    }
  }

  var content: String {
    switch self {
    case .changePassword: return L10n.Localizable.dwmOurAdviceContent
    case .savedNewPassword: return L10n.Localizable.dwmAdviceSectionSavePasswordContent
    }
  }

  var primaryButtonTitle: String {
    switch self {
    case .changePassword: return L10n.Localizable.dwmOurAdviceButton
    case .savedNewPassword: return L10n.Localizable.passwordResetViewAction
    }
  }

  var secondaryButtonTitle: String {
    switch self {
    case .changePassword: return ""
    case .savedNewPassword: return L10n.Localizable.actionItemCenterUndoButton
    }
  }

  var primaryAction: (() -> Void)? {
    switch self {
    case .changePassword(let action), .savedNewPassword(let action, _):
      return action
    }
  }

  var secondaryAction: (() -> Void)? {
    switch self {
    case .savedNewPassword(_, let action):
      return action
    default: return nil
    }
  }
}

struct DarkWebMonitoringAdviceSection: View {

  private let advice: DarkWebMonitoringAdvice
  private let primaryAction: (() -> Void)?
  private let secondaryAction: (() -> Void)?
  private let showPrimaryActionButton: Bool
  private let showSecondaryActionButton: Bool

  init(advice darkWebMonitoringAdvice: DarkWebMonitoringAdvice) {
    self.advice = darkWebMonitoringAdvice
    primaryAction = darkWebMonitoringAdvice.primaryAction
    secondaryAction = darkWebMonitoringAdvice.secondaryAction
    showPrimaryActionButton = primaryAction != nil
    showSecondaryActionButton = secondaryAction != nil
  }

  var body: some View {
    Section(advice.sectionTitle ?? "") {
      Infobox(
        advice.title ?? advice.content,
        description: advice.title != nil ? advice.content : nil
      ) {
        if showPrimaryActionButton {
          Button(advice.primaryButtonTitle) {
            primaryAction?()
          }
        }
        if showSecondaryActionButton {
          Button(advice.secondaryButtonTitle) {
            secondaryAction?()
          }
        }
      }
    }
  }
}

struct DarkWebMonitoringAdviceSection_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(dynamicTypePreview: false) {
      List {
        DarkWebMonitoringAdviceSection(advice: .changePassword({}))
        DarkWebMonitoringAdviceSection(advice: .savedNewPassword({}, {}))
      }
      .listStyle(.ds.insetGrouped)
    }.previewLayout(.sizeThatFits)
  }
}
