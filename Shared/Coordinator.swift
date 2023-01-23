import Foundation

@MainActor
protocol Coordinator: AnyObject {
    func start()
    func dismiss()
    func restore()
}

extension Coordinator {
    func dismiss() {
    }
    func restore() {
    }
}

@MainActor
protocol SubcoordinatorOwner: Coordinator {
    var subcoordinator: Coordinator? { get set }
    
    func startSubcoordinator(_ subcoordinator: Coordinator)
}

extension SubcoordinatorOwner {
    func startSubcoordinator(_ subcoordinator: Coordinator) {
        self.subcoordinator = subcoordinator
        subcoordinator.start()
    }
}
