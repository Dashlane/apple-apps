#if canImport(UIKit)
  import Foundation
  import UIKit

  public class GlobalMenuHandler: MainMenuHandler {

    private var handlers = [MainMenuHandler]()

    public static let shared = GlobalMenuHandler()

    public func register(_ handler: MainMenuHandler) {
      handlers.append(handler)
    }

    public func unregister(_ handler: MainMenuHandler) {
      handlers.removeAll(where: { $0 === handler })
    }

    public func update(_ builder: UIMenuBuilder) {
      handlers.forEach {
        $0.update(builder)
      }
    }

    public func handle(_ command: UICommand) -> Bool {
      for handler in handlers where handler.handle(command) == true {
        return true
      }
      return false
    }
  }
#endif
