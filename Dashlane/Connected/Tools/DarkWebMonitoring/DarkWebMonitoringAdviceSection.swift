import Foundation
import SwiftUI
import UIDelight
import DesignSystem

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
        VStack(spacing: 0) {
            sectionTitle

            Infobox(title: advice.title ?? advice.content, description: advice.title != nil ? advice.content : nil) {
                if showPrimaryActionButton {
                    Button(action: { primaryAction?() }, label: {
                        Text(advice.primaryButtonTitle)
                    })
                }
                if showSecondaryActionButton {
                    Button(action: { secondaryAction?() }, label: {
                        Text(advice.secondaryButtonTitle)
                    })
                }
            }
            .padding(8)
        }
    }

    @ViewBuilder
    private var sectionTitle: some View {
        if let sectionTitle = advice.sectionTitle {
            HStack {
                Text(sectionTitle.uppercased())
                    .foregroundColor(Color(asset: FiberAsset.grey01))
                    .font(.footnote)
                    .padding([.top, .horizontal], 16)
                Spacer()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(asset: FiberAsset.infoButton)
                .resizable()
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 4) {
                if let title = advice.title {
                    Text(title)
                        .font(.body)
                        .bold()
                }

                Text(advice.content)
                    .font(.subheadline)
                    .foregroundColor(Color(asset: FiberAsset.dwmBreachDetailMessageBody))
            }
        }
    }
}

struct DarkWebMonitoringAdviceSection_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: false) {
            DarkWebMonitoringAdviceSection(advice: .changePassword({}))
            DarkWebMonitoringAdviceSection(advice: .savedNewPassword({}, {}))
        }.previewLayout(.sizeThatFits)
    }
}
