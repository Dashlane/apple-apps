#if canImport(UIKit)
  import Foundation
  import StoreKit
  import CorePremium
  import CoreLocalization
  import CoreFeature

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
            frozenWarning = L10n.Core.planScreensFreeFrozenWarning
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

      if plan.introductoryOfferPaymentMode == .freeTrial, let period = plan.introductoryOfferPeriod
      {
        switch (period.unit, period.value) {
        case (.day, 1):
          return L10n.Core.introOffersPromoFirstDayFree
        case (.day, let numberOfUnits):
          return L10n.Core.introOffersPromoFirstXDaysFree(numberOfUnits)
        case (.week, 1):
          return L10n.Core.introOffersPromoFirstWeekFree
        case (.week, let numberOfUnits):
          return L10n.Core.introOffersPromoFirstXWeeksFree(numberOfUnits)
        case (.month, 1):
          return L10n.Core.introOffersPromoFirstMonthFree
        case (.month, let numberOfUnits):
          return L10n.Core.introOffersPromoFirstXMonthsFree(numberOfUnits)
        case (.year, 1):
          return L10n.Core.introOffersPromoFirstYearFree
        case (.year, let numberOfUnits):
          return L10n.Core.introOffersPromoFirstXYearsFree(numberOfUnits)
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
            return L10n.Core.introOffersPromoDiscountFirstMonth(roundedDiscount)
          case (.month, let numberOfUnits):
            return L10n.Core.introOffersPromoDiscountFirstXMonths(roundedDiscount, numberOfUnits)
          case (.year, 1):
            return L10n.Core.introOffersPromoDiscountFirstYear(roundedDiscount)
          case (.year, let numberOfUnits):
            return L10n.Core.introOffersPromoDiscountFirstXYears(roundedDiscount, numberOfUnits)
          default: break
          }
        } else {
          switch (period.unit, period.value * introductoryOfferNumberOfPeriod) {
          case (.month, 1):
            return L10n.Core.introOffersPromoSaveFirstMonth
          case (.month, let numberOfUnits):
            return L10n.Core.introOffersPromoSaveFirstXMonths(numberOfUnits)
          case (.year, 1):
            return L10n.Core.introOffersPromoSaveFirstYear
          case (.year, let numberOfUnits):
            return L10n.Core.introOffersPromoSaveFirstXYears(numberOfUnits)
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
          return L10n.Core.introOffersForOneDay
        case (.day, let numberOfUnits):
          return L10n.Core.introOffersForXDays(numberOfUnits)
        case (.week, 1):
          return L10n.Core.introOffersForOneWeek
        case (.week, let numberOfUnits):
          return L10n.Core.introOffersForXWeeks(numberOfUnits)
        case (.month, 1):
          return L10n.Core.introOffersForOneMonth
        case (.month, let numberOfUnits):
          return L10n.Core.introOffersForXMonths(numberOfUnits)
        case (.year, 1):
          return L10n.Core.introOffersForOneYear
        case (.year, let numberOfUnits):
          return L10n.Core.introOffersForXYears(numberOfUnits)
        default:
          return ""
        }
      } else if !isPeriodIdenticalToIntroductoryOfferPeriod
        && introductoryOfferPeriod?.unit == .month,
        let introductoryOfferNumberOfPeriod = introductoryOfferNumberOfPeriod
      {
        if introductoryOfferNumberOfPeriod == 1 {
          return L10n.Core.introOffersPerMonthForOneMonth
        } else {
          return L10n.Core.introOffersPerMonthForXMonths(introductoryOfferNumberOfPeriod)
        }
      } else if introductoryOfferPaymentMode == .payUpFront, let period = introductoryOfferPeriod,
        period.value > 1
      {
        switch introductoryOfferPeriod?.unit {
        case .month:
          return L10n.Core.introOffersPerXMonths(period.value)
        case .year:
          return L10n.Core.introOffersPerXYears(period.value)
        default:
          return ""
        }
      }

      return L10n.Core.plansPriceBilled(for: offer.duration)
    }

    var renewalPriceDescription: String? {
      guard isIntroductoryOffer else { return nil }

      switch subscription.period.unit {
      case .month:
        return L10n.Core.introOffersFinalPriceDescriptionMonthly(localizedNonDiscountedPrice)
      case .year:
        return L10n.Core.introOffersFinalPriceDescriptionYearly(localizedNonDiscountedPrice)
      default: break
      }

      return nil
    }
  }
#endif
