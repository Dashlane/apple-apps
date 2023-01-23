import Foundation
import Combine
import DashlaneReportKit
import DashTypes

final class ToolsViewModel: ObservableObject, SessionServicesInjecting {

    private let toolsService: ToolsServiceProtocol
    private let usageLogService: UsageLogServiceProtocol

    @Published
    private(set) var cells = [ToolsViewCellData]()

    private let didSelectItem: PassthroughSubject<ToolsItem, Never>

    private var cancellables = Set<AnyCancellable>()

    init(toolsService: ToolsServiceProtocol,
         usageLogService: UsageLogServiceProtocol,
         premiumService: PremiumServiceProtocol,
         didSelectItem: PassthroughSubject<ToolsItem, Never>) {
        self.toolsService = toolsService
        self.usageLogService = usageLogService
        self.didSelectItem = didSelectItem
        premiumService.premiumStatusPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.update()
            }
            .store(in: &cancellables)
    }

    private func update() {
        cells = toolsService.displayableItems()
    }

    func didSelect(item: ToolsItem) {
        usageLogService.post(UsageLogCode75GeneralActions(type: "tools", action: item.rawValue))
        didSelectItem.send(item)
    }
}

extension ToolsViewModel {
    static var mock: ToolsViewModel {
        ToolsViewModel(toolsService: ToolsServiceMock(),
                       usageLogService: UsageLogService.fakeService,
                       premiumService: PremiumServiceMock(),
                       didSelectItem: PassthroughSubject<ToolsItem, Never>())
    }
}
