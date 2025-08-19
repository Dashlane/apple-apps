import Foundation
import UIKit

@MainActor
public protocol MainMenuHandler: AnyObject {
  func update(_ builder: UIMenuBuilder)
  func handle(_ command: UICommand) -> Bool
}

public class MainMenuHandlerMock: MainMenuHandler {
  public func update(_ builder: UIMenuBuilder) {}
  public func handle(_ command: UICommand) -> Bool { false }
}
