import Foundation


public protocol InjectableViewController: AnyObject {
    associatedtype Input
    var input: Input! { get set }
}

extension InitialSceneType where T: InjectableViewController {
    func instantiate(input: T.Input) -> T {
        let viewController = instantiate()
        viewController.input = input
        return viewController
    }
}

extension SceneType where T: InjectableViewController {
    func instantiate(input: T.Input) -> T {
        let viewController = instantiate()
        viewController.input = input
        return viewController
    }
}
