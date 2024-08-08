import Combine
import CorePremium
import DashTypes
import Foundation

final class ToolsViewModel: ObservableObject, SessionServicesInjecting {

  private let toolsService: ToolsServiceProtocol

  @Published
  private(set) var tools = [ToolInfo]()

  private let didSelectItem: PassthroughSubject<ToolsItem, Never>

  init(
    toolsService: ToolsServiceProtocol,
    didSelectItem: PassthroughSubject<ToolsItem, Never>
  ) {
    self.toolsService = toolsService
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
      toolsService: .mock(capabilities: []),
      didSelectItem: PassthroughSubject<ToolsItem, Never>())
  }
}
