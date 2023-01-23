import SwiftUI
import CorePremium
import UIDelight
import UIComponents

struct ActivePlanSettingsSection: View {
    let status: PremiumStatus
    let showPurchase: () -> Void

    var plan: ActivePlan {
        return status.humanReadableActivePlan
    }

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 3) {
                AdaptiveHStack(verticalAlignment: .center, spacing: 2) {
                    title
                    actionButton
                }
                subtitle
            }.padding(.vertical, 10)
                          }
    }

    var title: some View {
        Text(plan.localizedTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title))
    }

    @ViewBuilder
    var subtitle: some View {
        if let info = status.localizedInfo {
            Text(info)
                .font(.subheadline)
                .foregroundColor(Color(asset: FiberAsset.secondaryText))
        }
    }

    @ViewBuilder
    var actionButton: some View {
        if let action = status.planAction {
            Button(action: showPurchase) {
                Text(action.localizedTitle)
            }.accentColor(Color(asset: FiberAsset.accentColor))
        }
    }

        }

fileprivate extension PremiumStatus {
    typealias L10n = Dashlane.L10n.Localizable.Settings.ActivePlan
    var localizedInfo: String? {
        switch humanReadableActivePlan {
        case .legacy:
            return L10n.legacyFreeUserSubtitle

        case .free:
            return nil

        case .trial:
            guard let nbDays = daysToExpiration() else {
                return nil
            }

            return L10n.trialDaysLeftSubtitle(nbDays)

        case .premium(.freeForLife):
            return L10n.premiumForLifeSubtitle
        case .premium(.freeOfCharge):
            guard let endDateInfo = localizedEndDateInfo else {
                return L10n.premiumFreeOfChargeSubtitle
            }

            return  [L10n.premiumFreeOfChargeSubtitle, endDateInfo].joined(separator: " ")

        case .premium(.standard),
             .premiumPlus,
             .premiumFamily,
             .premiumPlusFamily,
             .essentials,
             .advanced:
            return localizedEndDateInfo
        }
    }

    var localizedEndDateInfo: String? {
        guard let date = endDate else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateText = formatter.string(from: date)

        if autoRenewal ?? false {
            return L10n.renewSubtitle(dateText)
        } else {
            return L10n.expiresSubtitle(dateText)
        }
    }
}

fileprivate extension PremiumStatus {
    enum PlanAction {
        case change
        case upgrade

        var localizedTitle: String {
            switch self {
            case .change:
                return L10n.changePlanButton
            case .upgrade:
                return L10n.upgradeButton
            }
        }
    }
    var planAction: PlanAction? {
        switch humanReadableActivePlan {
        case .legacy,
             .essentials,
             .advanced,
             .premium(.standard),
             .premium(.freeForLife),
             .premiumPlus,
             .premiumFamily(isAdmin: true),
             .premiumPlusFamily(isAdmin: true):
            return .change
        case .free, .trial:
            return .upgrade

        case .premiumFamily(isAdmin: false),
             .premiumPlusFamily(isAdmin: false),
             .premium(.freeOfCharge):
            return nil
        }
    }
}

 struct PremiumStatusSectionView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            List {
                ActivePlanSettingsSection(status: .Mock.freeTrial) {}

                ActivePlanSettingsSection(status: .Mock.free) {}
                ActivePlanSettingsSection(status: .Mock.legacy) {}
            }
            .listStyle(.insetGrouped)
            .previewDisplayName("Free and trial")
        }

        List {
            ActivePlanSettingsSection(status: .Mock.premiumWithAutoRenew) {}
            ActivePlanSettingsSection(status: .Mock.premiumWithoutAutoRenew) {}

        }
        .listStyle(.insetGrouped)
        .previewDisplayName("Premium")

        List {
            ActivePlanSettingsSection(status: .Mock.premiumLifeTime) {}
            ActivePlanSettingsSection(status: .Mock.premiumFreeOfCharge) {}
        }
        .listStyle(.insetGrouped)
        .previewDisplayName("Special Premium")

        List {
            ActivePlanSettingsSection(status: .Mock.premiumPlusWithAutoRenew) {}
            ActivePlanSettingsSection(status: .Mock.premiumPlusWithoutAutoRenew) {}
        }
        .listStyle(.insetGrouped)
        .previewDisplayName("Premium Plus")

        List {
            ActivePlanSettingsSection(status: .Mock.familyAdmin) {}
            ActivePlanSettingsSection(status: .Mock.familyInvitee) {}
            ActivePlanSettingsSection(status: .Mock.familyPlusAdmin) {}
            ActivePlanSettingsSection(status: .Mock.familyPlusInvitee) {}
        }
        .listStyle(.insetGrouped)
        .previewDisplayName("Family")
    }
 }
