import Foundation

protocol EmptyVaultViewModelProtocol {
    func dismissPopover()
}

class EmptyVaultViewModelMock: EmptyVaultViewModelProtocol {
    func dismissPopover() {
        print("Dismiss popover")
    }
}
