import Foundation
import Combine
import DashTypes
import CorePremium

final class ToolsViewModel: ObservableObject, SessionServicesInjecting {

    private let toolsService: ToolsServiceProtocol

    @Published
    private(set) var tools = [ToolInfo]()

    private let didSelectItem: PassthroughSubject<ToolsItem, Never>

    init(toolsService: ToolsServiceProtocol,
         premiumService: PremiumServiceProtocol,
         didSelectItem: PassthroughSubject<ToolsItem, Never>) {
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
        ToolsViewModel(toolsService: .mock(),
                       premiumService: PremiumServiceMock(),
                       didSelectItem: PassthroughSubject<ToolsItem, Never>())
    }
}
