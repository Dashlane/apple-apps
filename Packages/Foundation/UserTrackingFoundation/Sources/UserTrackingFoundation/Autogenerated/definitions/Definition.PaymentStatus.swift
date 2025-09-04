import Foundation

extension Definition {

  public enum `PaymentStatus`: String, Encodable, Sendable {
    case `assignedPlanSameTierAsCurrentPlan` = "assigned_plan_same_tier_as_current_plan"
    case `b2BPlanNotFound` = "b2b_plan_not_found"
    case `cannotInvoiceFreePlan` = "cannot_invoice_free_plan"
    case `changeTierAmountTooExpensive` = "change_tier_amount_too_expensive"
    case `currentPlanStartDateInFuture` = "current_plan_start_date_in_future"
    case `errorCalculatingTierChange` = "error_calculating_tier_change"
    case `forbiddenEmailDomain` = "forbidden_email_domain"
    case `insufficientAmount` = "insufficient_amount"
    case `invalidPlan` = "invalid_plan"
    case `noKeyForUser` = "no_key_for_user"
    case `notBillingAdmin` = "not_billing_admin"
    case `notEligibleToChangeTierMidCycle` = "not_eligible_to_change_tier_mid_cycle"
    case `notInATeamPlan` = "not_in_a_team_plan"
    case `notInFreeTrial` = "not_in_free_trial"
    case `notTeamCaptain` = "not_team_captain"
    case `paymentErrorDuringUpgrade` = "payment_error_during_upgrade"
    case `paymentMeanIsNotCreditCard` = "payment_mean_is_not_credit_card"
    case `paymentMeanIsNotInvoice` = "payment_mean_is_not_invoice"
    case `salesTaxMismatch` = "sales_tax_mismatch"
    case `seatsToPurchaseLowerActualUsage` = "seats_to_purchase_lower_actual_usage"
    case `selectedPlanIsNotValid` = "selected_plan_is_not_valid"
    case `starterPlanNot10Seats` = "starter_plan_not_10_seats"
    case `success`
    case `teamHasSsoEnabled` = "team_has_sso_enabled"
    case `unsupportedPaymentMean` = "unsupported_payment_mean"
    case `userSubscribingNotFound` = "user_subscribing_not_found"
    case `vatNumberNotUpserted` = "vat_number_not_upserted"
    case `wrongAmountToPay` = "wrong_amount_to_pay"
  }
}
