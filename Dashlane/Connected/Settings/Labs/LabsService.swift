import Foundation
import DashTypes
import DashlaneAppKit
import CoreFeature

public struct LabsService {
    var isLabsAvailable: Bool {
        return BuildEnvironment.current == .debug || BuildEnvironment.current.isQA || BuildEnvironment.current.isNightly
    }

    var eligibleFeatures: [ControlledFeature] {
                return ControlledFeature.allCases
    }
}
