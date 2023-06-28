import Foundation

public struct PreviousPlan: Decodable {
    public let planId: String
    public let endDate: Date
    public let startDate: Date
    public let statusCode: Int
}

internal enum PreviousPlanType: Decodable {
    case plan(PreviousPlan)
    case noPlan
}

extension PreviousPlanType {

    public init(from decoder: Decoder) throws {
        let container =  try decoder.singleValueContainer()
        do {
            let previousPlan = try container.decode(PreviousPlan.self)
            self = .plan(previousPlan)
        } catch {
                                                            self = .noPlan
        }
    }
}
