import Foundation
import SafariServices

class EmptyVaultViewModel: EmptyVaultViewModelProtocol {
    
    let safariExtensionService: SafariExtensionServiceProtocol
    
    init(safariExtensionService: SafariExtensionServiceProtocol) {
        self.safariExtensionService = safariExtensionService
    }
    
    func dismissPopover() {
        safariExtensionService.dismissPopover()
    }
}

extension EmptyVaultViewModel {
    static func mock() -> EmptyVaultViewModel {
        EmptyVaultViewModel(safariExtensionService: SafariExtensionServiceMock())
    }
}
