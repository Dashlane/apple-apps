import Foundation

extension Definition {

  public enum `PlanBillingPeriod`: String, Encodable, Sendable {
    case `monthly`
    case `yearly`
  }
}
