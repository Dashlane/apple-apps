import Foundation

extension Definition {

  public enum `CancelPlanStep`: String, Encodable, Sendable {
    case `abandon`
    case `cancelError` = "cancel_error"
    case `contactSupport` = "contact_support"
    case `selectedCancellationReason` = "selected_cancellation_reason"
    case `start`
    case `successCancel` = "success_cancel"
    case `successCancelAndErrorRefund` = "success_cancel_and_error_refund"
    case `successRefund` = "success_refund"
  }
}
