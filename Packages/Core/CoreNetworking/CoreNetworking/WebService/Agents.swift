import Foundation
import SwiftTreats
import DashTypes

struct UserAgent: Encodable, CustomStringConvertible {
    let version: String = Application.version()
    let platform: String
    let osversion: String = osVersion()

    init(platform: Platform) {
        self.platform = platform.rawValue
    }

    var description: String {
        return "{version:\(version),platform:\(platform),osversion:\(osversion)}"
    }
}

private func osVersion() -> String {
    let systemVersion = Device.systemVersion
    let osversion = systemVersion.isEmpty ? "0" : systemVersion
    return osversion
}
