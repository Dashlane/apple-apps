import Foundation

extension ProcessInfo {
     public var isPreview: Bool {
        #if DEBUG
        return environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        return false
        #endif
    }
}
