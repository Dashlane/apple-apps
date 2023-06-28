#if canImport(UIKit)
import Foundation
import UIKit

public protocol MainMenuHandler: AnyObject {
    func update(_ builder: UIMenuBuilder)
    func handle(_ command: UICommand) -> Bool
}

public class MainMenuHandlerMock: MainMenuHandler {
    public func update(_ builder: UIMenuBuilder) { }
    public func handle(_ command: UICommand) -> Bool { false }
}
#endif
