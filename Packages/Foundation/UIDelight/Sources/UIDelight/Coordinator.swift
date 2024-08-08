import Foundation

@MainActor
public protocol Coordinator: AnyObject {
  func start()
  func dismiss()
  func restore()
}

extension Coordinator {
  public func dismiss() {}
  public func restore() {}
}

@MainActor
public protocol SubcoordinatorOwner: Coordinator {
  var subcoordinator: Coordinator? { get set }

  func startSubcoordinator(_ subcoordinator: Coordinator)
}

extension SubcoordinatorOwner {
  public func startSubcoordinator(_ subcoordinator: Coordinator) {
    self.subcoordinator = subcoordinator
    subcoordinator.start()
  }
}
