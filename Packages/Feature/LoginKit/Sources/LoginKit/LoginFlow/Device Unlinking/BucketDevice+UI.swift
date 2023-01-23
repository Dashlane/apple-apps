import Foundation
import CoreSession
import CoreLocalization

extension BucketDevice.Platform {
    var imageAsset: ImageAsset {
        switch self {
            case .iphone, .ipad, .ipod, .macos, .catalyst:
                return Asset.applePlatform
            case .windows:
                return Asset.windowsPlatform
            case .android:
                return Asset.androidPlatform
            case .web:
                return Asset.webPlatform
        }
    }
}

extension BucketDevice {
    var displayedName: String {
        guard platform == .web else {
            return name
        }

        let lowercasedName = name.lowercased()
        if lowercasedName.contains("mac") {
            return "Mac"
        } else if lowercasedName.contains("windows") {
            return "Windows"
        } else if lowercasedName.contains("linux") {
            return "Linux"
        } else {
            return name
        }
    }

    var displayedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let timeAgo = formatter.localizedString(for: lastActivityDate, relativeTo: Date())
        return L10n.Core.deviceUnlinkingUnlinkLastActive(timeAgo)
    }
}

extension DeviceListEntry: Identifiable {
    public var id: String {
        displayedDevice.id
    }
}
