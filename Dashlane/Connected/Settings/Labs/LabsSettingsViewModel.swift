import UIKit
import DashTypes
import CoreFeature
import DashlaneAppKit

final class LabsSettingsViewModel: ObservableObject, SessionServicesInjecting {

    struct FeatureFlip: Identifiable {
        let name: String
        let isOn: Bool

        var id: String {
            name
        }
    }

    let featureFlipService: FeatureServiceProtocol
    let labsService: LabsService
    let featureFlips: [FeatureFlip]

    init(featureFlipService: FeatureServiceProtocol,
         labsService: LabsService) {
        self.featureFlipService = featureFlipService
        self.labsService = labsService
        self.featureFlips = labsService.eligibleFeatures
            .filter { featureFlipService.isEnabled($0) } 
            .sorted { (right, left) -> Bool in
                return right.rawValue.lowercased() < left.rawValue.lowercased() 
            }
            .map { FeatureFlip(name: $0.rawValue, isOn: featureFlipService.isEnabled($0)) }
    }

    func goToFeedbackForm() {
        if let url = URL(string: "_") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension LabsSettingsViewModel {

    static var mock: LabsSettingsViewModel {
        LabsSettingsViewModel(featureFlipService: .mock(),
                              labsService: LabsService())
    }
}
