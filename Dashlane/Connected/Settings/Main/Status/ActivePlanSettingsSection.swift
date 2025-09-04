import CoreFeature
import CoreLocalization
import CorePremium
import CoreTypes
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

struct ActivePlanSettingsSection: View {
  let status: CorePremium.Status.B2cStatus
  var vaultState: VaultState
  let showPurchase: () -> Void
  let learnMore: () -> Void

  var showFrozenRestrictions: Bool {
    vaultState == .frozen
  }

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
      }.padding(.vertical, showFrozenRestrictions ? 0 : 10)

      if showFrozenRestrictions {
        learnMoreAboutFrozen
      }
    }
  }

  var title: some View {
    Text(plan.localizedTitle)
      .frame(maxWidth: .infinity, alignment: .leading)
      .textStyle(.title.section.medium)
      .foregroundStyle(Color.ds.text.neutral.standard)
  }

  @ViewBuilder
  var subtitle: some View {
    if let info = status.localizedInfo {
      Text(info)
        .textStyle(.body.reduced.regular)
        .foregroundStyle(Color.ds.text.neutral.quiet)
    } else if showFrozenRestrictions {
      Text(CoreL10n.settingsHeaderFrozenAcountWarning)
        .textStyle(.body.reduced.regular)
        .foregroundStyle(Color.ds.text.danger.standard)
    }
  }

  @ViewBuilder
  var actionButton: some View {
    if let action = status.planAction {
      Button(action: showPurchase) {
        Text(action.localizedTitle)
      }
      .tint(.ds.text.brand.standard)
      .foregroundStyle(Color.ds.text.brand.standard)
    }
  }

  var learnMoreAboutFrozen: some View {
    Button(CoreL10n.settingsHeaderFrozenAcountLearnMore) {
      learnMore()
    }.foregroundStyle(Color.ds.text.neutral.standard)
  }
}

extension CorePremium.Status.B2cStatus {
  fileprivate typealias L10n = Dashlane.L10n.Localizable.Settings.ActivePlan
  fileprivate var localizedInfo: String? {
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

      return [L10n.premiumFreeOfChargeSubtitle, endDateInfo].joined(separator: " ")

    case .premium(.standard),
      .premiumPlus,
      .premiumFamily,
      .premiumPlusFamily,
      .essentials,
      .advanced:
      return localizedEndDateInfo
    }
  }

  fileprivate var localizedEndDateInfo: String? {
    guard let endDate = endDate else {
      return nil
    }

    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    let dateText = formatter.string(from: endDate)

    if autoRenewal {
      return L10n.renewSubtitle(dateText)
    } else {
      return L10n.expiresSubtitle(dateText)
    }
  }
}

extension Calendar {
  fileprivate func dateComponents(
    _ components: Set<Calendar.Component>, toStartOfTheDayOf end: Date
  ) -> DateComponents {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let endDateUpdated = calendar.startOfDay(for: end)
    return calendar.dateComponents(components, from: today, to: endDateUpdated)
  }
}

extension CorePremium.Status.B2cStatus {
  fileprivate enum PlanAction {
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

  fileprivate var planAction: PlanAction? {
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
        ActivePlanSettingsSection(
          status: CorePremium.Status.Mock.freeTrial.b2cStatus, vaultState: .default,
          showPurchase: {}, learnMore: {})
        ActivePlanSettingsSection(
          status: CorePremium.Status.Mock.free.b2cStatus, vaultState: .default, showPurchase: {},
          learnMore: {})
        ActivePlanSettingsSection(
          status: CorePremium.Status.Mock.legacy.b2cStatus, vaultState: .default, showPurchase: {},
          learnMore: {})
      }
      .listStyle(.ds.insetGrouped)
      .previewDisplayName("Free and trial")
    }

    List {
      ActivePlanSettingsSection(
        status: CorePremium.Status.Mock.premiumWithAutoRenew.b2cStatus, vaultState: .default,
        showPurchase: {}, learnMore: {})
      ActivePlanSettingsSection(
        status: CorePremium.Status.Mock.premiumWithoutAutoRenew.b2cStatus, vaultState: .default,
        showPurchase: {}, learnMore: {})

    }
    .listStyle(.ds.insetGrouped)
    .previewDisplayName("Premium")

    List {
      ActivePlanSettingsSection(
        status: CorePremium.Status.Mock.premiumLifeTime.b2cStatus, vaultState: .default,
        showPurchase: {}, learnMore: {})
      ActivePlanSettingsSection(
        status: CorePremium.Status.Mock.premiumFreeOfCharge.b2cStatus, vaultState: .default,
        showPurchase: {}, learnMore: {})
    }
    .listStyle(.ds.insetGrouped)
    .previewDisplayName("Special Premium")

    List {
      ActivePlanSettingsSection(
        status: CorePremium.Status.Mock.premiumPlusWithAutoRenew.b2cStatus, vaultState: .default,
        showPurchase: {}, learnMore: {})
      ActivePlanSettingsSection(
        status: CorePremium.Status.Mock.premiumPlusWithoutAutoRenew.b2cStatus, vaultState: .default,
        showPurchase: {}, learnMore: {})
    }
    .listStyle(.ds.insetGrouped)
    .previewDisplayName("Premium Plus")

    List {
      ActivePlanSettingsSection(
        status: CorePremium.Status.Mock.familyAdmin.b2cStatus, vaultState: .default,
        showPurchase: {}, learnMore: {})
      ActivePlanSettingsSection(
        status: CorePremium.Status.Mock.familyInvitee.b2cStatus, vaultState: .default,
        showPurchase: {}, learnMore: {})
      ActivePlanSettingsSection(
        status: CorePremium.Status.Mock.familyPlusAdmin.b2cStatus, vaultState: .default,
        showPurchase: {}, learnMore: {})
      ActivePlanSettingsSection(
        status: CorePremium.Status.Mock.familyPlusInvitee.b2cStatus, vaultState: .default,
        showPurchase: {}, learnMore: {})
    }
    .listStyle(.ds.insetGrouped)
    .previewDisplayName("Family")
  }
}
