import Foundation
import UIKit

protocol MainMenuHandler: AnyObject {
    func update(_ builder: UIMenuBuilder)
    func handle(_ command: UICommand) -> Bool
}

class MainMenuHandlerMock: MainMenuHandler {
    func update(_ builder: UIMenuBuilder) { }
    func handle(_ command: UICommand) -> Bool { false }
}
