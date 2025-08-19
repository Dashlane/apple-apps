import Combine
import CoreFeature
import CorePremium
import CoreTypes
import Foundation

final class ToolsViewModel: ObservableObject, SessionServicesInjecting {

  private let toolsService: ToolsServiceProtocol

  @Published
  private(set) var tools = [ToolInfo]()

  private let didSelectItem: PassthroughSubject<ToolsItem, Never>

  init(
    featureService: FeatureServiceProtocol,
    premiumStatusServicesSuit: PremiumStatusServicesSuit,
    didSelectItem: PassthroughSubject<ToolsItem, Never>
  ) {
    self.toolsService = ToolsService(
      featureService: featureService, capabilityService: premiumStatusServicesSuit.capabilityService
    )
    self.didSelectItem = didSelectItem
    toolsService.displayableTools().assign(to: &$tools)
  }

  func didSelect(_ item: ToolsItem) {
    didSelectItem.send(item)
  }
}

extension ToolsViewModel {
  static var mock: ToolsViewModel {
    ToolsViewModel(
      featureService: .mock(),
      premiumStatusServicesSuit: .mock,
      didSelectItem: PassthroughSubject<ToolsItem, Never>())
  }
}
