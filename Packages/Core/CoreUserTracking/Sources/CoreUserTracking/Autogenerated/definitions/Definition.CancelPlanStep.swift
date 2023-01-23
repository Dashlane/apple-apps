import Foundation

extension Definition {

public enum `CancelPlanStep`: String, Encodable {
case `abandon`
case `cancelError` = "cancel_error"
case `contactSupport` = "contact_support"
case `start`
case `successCancel` = "success_cancel"
case `successCancelAndErrorRefund` = "success_cancel_and_error_refund"
case `successRefund` = "success_refund"
}
}