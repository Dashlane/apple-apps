import DashTypes
import Foundation

extension System {
  static var platform: String {
    return Platform.passwordManager.rawValue
  }
}