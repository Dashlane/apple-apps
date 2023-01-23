import Foundation

extension Definition {

public enum `CallToAction`: String, Encodable {
case `allOffers` = "all_offers"
case `contactCustomerSupport` = "contact_customer_support"
case `contactPhoneSupport` = "contact_phone_support"
case `doNotLinkWebsite` = "do_not_link_website"
case `essentialOffer` = "essential_offer"
case `familyOffer` = "family_offer"
case `linkWebsite` = "link_website"
case `openChromeWebStore` = "open_chrome_web_store"
case `planDetails` = "plan_details"
case `premiumOffer` = "premium_offer"
case `redeemOffer` = "redeem_offer"
case `requestCall` = "request_call"
case `requestUpgrade` = "request_upgrade"
case `reviewBad` = "review_bad"
case `reviewGreat` = "review_great"
case `reviewOk` = "review_ok"
case `sendEmail` = "send_email"
case `termsOfService` = "terms_of_service"
case `unlink`
}
}