import Foundation
import DashTypes

extension System {
    static var platform: String {
        return Platform.passwordManager.rawValue
    }
}
