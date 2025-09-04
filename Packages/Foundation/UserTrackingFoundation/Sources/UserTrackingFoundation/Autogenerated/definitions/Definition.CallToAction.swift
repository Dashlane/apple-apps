import Foundation

extension Definition {

  public enum `CallToAction`: String, Encodable, Sendable {
    case `abandonRefundRequest` = "abandon_refund_request"
    case `allOffers` = "all_offers"
    case `buyDashlane` = "buy_dashlane"
    case `buySeats` = "buy_seats"
    case `cancel`
    case `cancelSubscription` = "cancel_subscription"
    case `changeCompromisedPassword` = "change_compromised_password"
    case `changeReusedPassword` = "change_reused_password"
    case `changeWeakPassword` = "change_weak_password"
    case `close`
    case `confirm`
    case `confirmCancellation` = "confirm_cancellation"
    case `confirmRefundRequest` = "confirm_refund_request"
    case `contactCustomerSupport` = "contact_customer_support"
    case `contactPhoneSupport` = "contact_phone_support"
    case `continueCancellation` = "continue_cancellation"
    case `createPersonalAccount` = "create_personal_account"
    case `dismiss`
    case `doNotLinkWebsite` = "do_not_link_website"
    case `essentialOffer` = "essential_offer"
    case `extendTrial` = "extend_trial"
    case `familyOffer` = "family_offer"
    case `freeOffer` = "free_offer"
    case `installExtension` = "install_extension"
    case `keepPremium` = "keep_premium"
    case `linkWebsite` = "link_website"
    case `notNow` = "not_now"
    case `okGotIt` = "ok_got_it"
    case `openChromeWebStore` = "open_chrome_web_store"
    case `openG2RatingWebsite` = "open_g2_rating_website"
    case `payByInvoice` = "pay_by_invoice"
    case `payWithCreditCard` = "pay_with_credit_card"
    case `planDetails` = "plan_details"
    case `premiumOffer` = "premium_offer"
    case `redeemOffer` = "redeem_offer"
    case `registerWebinar` = "register_webinar"
    case `remindMeLater` = "remind_me_later"
    case `requestCall` = "request_call"
    case `requestDemo` = "request_demo"
    case `requestUpgrade` = "request_upgrade"
    case `restartPremiumSubscription` = "restart_premium_subscription"
    case `reviewBad` = "review_bad"
    case `reviewGreat` = "review_great"
    case `reviewOk` = "review_ok"
    case `seeAllPlans` = "see_all_plans"
    case `seeUsers` = "see_users"
    case `send`
    case `sendEmail` = "send_email"
    case `skip`
    case `termsOfService` = "terms_of_service"
    case `unfreezeAccount` = "unfreeze_account"
    case `unlink`
    case `upgradeToBusiness` = "upgrade_to_business"
    case `upgradeToBusinessPlus` = "upgrade_to_business_plus"
  }
}
