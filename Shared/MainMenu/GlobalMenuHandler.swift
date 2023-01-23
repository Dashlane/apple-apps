import Foundation
import UIKit

class GlobalMenuHandler: MainMenuHandler {

    private var handlers = [MainMenuHandler]()

    static let shared = GlobalMenuHandler()

    func register(_ handler: MainMenuHandler) {
        handlers.append(handler)
    }

    func unregister(_ handler: MainMenuHandler) {
        handlers.removeAll(where: { $0 === handler })
    }

        func update(_ builder: UIMenuBuilder) {
        handlers.forEach {
            $0.update(builder)
        }
    }

            func handle(_ command: UICommand) -> Bool {
        for handler in handlers {
            if handler.handle(command) {
                return true
            }
        }
        return false
    }
}
