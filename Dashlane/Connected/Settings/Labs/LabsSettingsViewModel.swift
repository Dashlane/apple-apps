import Combine
import CoreFeature
import DashTypes
import DashlaneAPI
import UIKit

@MainActor
final class LabsSettingsViewModel: ObservableObject {

  let featureService: FeatureServiceProtocol

  @Published
  var experiences: [LabsExperience] = []

  private var cancellables = Set<AnyCancellable>()

  init(featureService: FeatureServiceProtocol) {
    self.featureService = featureService

    $experiences
      .receive(on: DispatchQueue.main)
      .sink { experiences in
        featureService.save(experiences)
      }
      .store(in: &cancellables)
  }

  func fetch() async {
    do {
      experiences = try await featureService.labs()
    } catch {
      experiences = []
    }
  }

  func goToFeedbackForm() {
    if let url = URL(string: "_") {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
}

extension LabsSettingsViewModel {
  static var mock: LabsSettingsViewModel {
    LabsSettingsViewModel(
      featureService: .mock(labsExperiences: [
        LabsExperience(
          feature: .removeDuplicates,
          displayName: "Remove duplicates",
          displayDescription:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
          isOn: true)
      ]))
  }
}
