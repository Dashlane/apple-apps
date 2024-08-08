import Foundation

extension Definition {

  public enum `ToastName`: String, Encodable, Sendable {
    case `insufficientSeatsProvisioningError` = "insufficient_seats_provisioning_error"
    case `noMoreSeatsAvailableToProvision` = "no_more_seats_available_to_provision"
  }
}
