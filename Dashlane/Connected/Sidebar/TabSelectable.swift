import Foundation

protocol TabSelectable { 
                                func selectTab(_ tab: ConnectedCoordinator.Tab, flow: any TabFlow)
    func selectTab(_ tab: ConnectedCoordinator.Tab)
}
