import CoreLocalization
import CorePremium
import CoreTypes
import Foundation
import StoreKit

public class PurchasePlanRowModel: ObservableObject {
  let planTier: PlanTier
  let plan: PurchasePlan
  let vaultStateService: VaultStateServiceProtocol?

  @Published
  var hasLock: Bool = false
  @Published
  var frozenWarning: String?

  init(planTier: PlanTier, plan: PurchasePlan, vaultStateService: VaultStateServiceProtocol?) {
    self.planTier = planTier
    self.plan = plan
    self.vaultStateService = vaultStateService

    vaultStateService?.vaultStatePublisher()
      .receive(on: DispatchQueue.main)
      .sinkOnce { [weak self] state in
        guard let self = self else { return }
        if (state == .frozen) && (plan.kind == .free) {
          hasLock = true
          frozenWarning = CoreL10n.planScreensFreeFrozenWarning
        }
      }
  }

  var showPrice: Bool {
    return plan.kind != .free
  }

  var showStrikedthroughPrice: Bool {
    guard !showRenewalPrice else { return false }
    guard plan.isDiscountedOffer || plan.isIntroductoryOffer else { return false }
    guard plan.isPeriodIdenticalToIntroductoryOfferPeriod else { return false }

    return true
  }

  var showRenewalPrice: Bool {
    guard plan.isDiscountedOffer || plan.isIntroductoryOffer else { return false }
    guard
      (plan.introductoryOfferPaymentMode == .payUpFront
        && plan.introductoryOfferPeriod?.value ?? 0 > 1)
        || !plan.isPeriodIdenticalToIntroductoryOfferPeriod
    else { return false }

    return true
  }

  var promotionalMessage: String? {
    guard plan.isIntroductoryOffer else { return nil }

    if plan.introductoryOfferPaymentMode == .freeTrial, let period = plan.introductoryOfferPeriod {
      switch (period.unit, period.value) {
      case (.day, 1):
        return CoreL10n.introOffersPromoFirstDayFree
      case (.day, let numberOfUnits):
        return CoreL10n.introOffersPromoFirstXDaysFree(numberOfUnits)
      case (.week, 1):
        return CoreL10n.introOffersPromoFirstWeekFree
      case (.week, let numberOfUnits):
        return CoreL10n.introOffersPromoFirstXWeeksFree(numberOfUnits)
      case (.month, 1):
        return CoreL10n.introOffersPromoFirstMonthFree
      case (.month, let numberOfUnits):
        return CoreL10n.introOffersPromoFirstXMonthsFree(numberOfUnits)
      case (.year, 1):
        return CoreL10n.introOffersPromoFirstYearFree
      case (.year, let numberOfUnits):
        return CoreL10n.introOffersPromoFirstXYearsFree(numberOfUnits)
      default: break
      }
    } else if let period = plan.introductoryOfferPeriod,
      let introductoryOfferNumberOfPeriod = plan.introductoryOfferNumberOfPeriod
    {
      if plan.isPeriodIdenticalToIntroductoryOfferPeriod {
        let exactDiscount = 1 - (plan.price / plan.nonDiscountedPrice)
        let roundedDiscount = exactDiscount.formatted(.number.scale(100).rounded(increment: 1))

        switch (period.unit, period.value * introductoryOfferNumberOfPeriod) {
        case (.month, 1):
          return CoreL10n.introOffersPromoDiscountFirstMonth(roundedDiscount)
        case (.month, let numberOfUnits):
          return CoreL10n.introOffersPromoDiscountFirstXMonths(roundedDiscount, numberOfUnits)
        case (.year, 1):
          return CoreL10n.introOffersPromoDiscountFirstYear(roundedDiscount)
        case (.year, let numberOfUnits):
          return CoreL10n.introOffersPromoDiscountFirstXYears(roundedDiscount, numberOfUnits)
        default: break
        }
      } else {
        switch (period.unit, period.value * introductoryOfferNumberOfPeriod) {
        case (.month, 1):
          return CoreL10n.introOffersPromoSaveFirstMonth
        case (.month, let numberOfUnits):
          return CoreL10n.introOffersPromoSaveFirstXMonths(numberOfUnits)
        case (.year, 1):
          return CoreL10n.introOffersPromoSaveFirstYear
        case (.year, let numberOfUnits):
          return CoreL10n.introOffersPromoSaveFirstXYears(numberOfUnits)
        default: break
        }
      }
    }

    return nil
  }

  var periodDescription: String {
    return plan.periodDescription
  }

  var renewalPriceDescription: String? {
    if showRenewalPrice {
      return plan.renewalPriceDescription
    }

    return nil
  }
}

extension PurchasePlanRowModel: Identifiable {
  public var id: PurchasePlan.Kind {
    return plan.kind
  }
}

extension PurchasePlan {
  var periodDescription: String {
    if introductoryOfferPaymentMode == .freeTrial, let period = introductoryOfferPeriod {
      switch (period.unit, period.value) {
      case (.day, 1):
        return CoreL10n.introOffersForOneDay
      case (.day, let numberOfUnits):
        return CoreL10n.introOffersForXDays(numberOfUnits)
      case (.week, 1):
        return CoreL10n.introOffersForOneWeek
      case (.week, let numberOfUnits):
        return CoreL10n.introOffersForXWeeks(numberOfUnits)
      case (.month, 1):
        return CoreL10n.introOffersForOneMonth
      case (.month, let numberOfUnits):
        return CoreL10n.introOffersForXMonths(numberOfUnits)
      case (.year, 1):
        return CoreL10n.introOffersForOneYear
      case (.year, let numberOfUnits):
        return CoreL10n.introOffersForXYears(numberOfUnits)
      default:
        return ""
      }
    } else if !isPeriodIdenticalToIntroductoryOfferPeriod
      && introductoryOfferPeriod?.unit == .month,
      let introductoryOfferNumberOfPeriod = introductoryOfferNumberOfPeriod
    {
      if introductoryOfferNumberOfPeriod == 1 {
        return CoreL10n.introOffersPerMonthForOneMonth
      } else {
        return CoreL10n.introOffersPerMonthForXMonths(introductoryOfferNumberOfPeriod)
      }
    } else if introductoryOfferPaymentMode == .payUpFront, let period = introductoryOfferPeriod,
      period.value > 1
    {
      switch introductoryOfferPeriod?.unit {
      case .month:
        return CoreL10n.introOffersPerXMonths(period.value)
      case .year:
        return CoreL10n.introOffersPerXYears(period.value)
      default:
        return ""
      }
    }

    return CoreL10n.plansPriceBilled(for: offer.duration)
  }

  var renewalPriceDescription: String? {
    guard isIntroductoryOffer else { return nil }

    switch subscription.period.unit {
    case .month:
      return CoreL10n.introOffersFinalPriceDescriptionMonthly(localizedNonDiscountedPrice)
    case .year:
      return CoreL10n.introOffersFinalPriceDescriptionYearly(localizedNonDiscountedPrice)
    default: break
    }

    return nil
  }
}
