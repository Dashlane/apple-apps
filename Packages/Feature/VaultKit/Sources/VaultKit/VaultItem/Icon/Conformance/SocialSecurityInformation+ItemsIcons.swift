import Foundation
import SwiftUI
import CorePersonalData
import DesignSystem

extension SocialSecurityInformation {
    public var listIcon: VaultItemIcon {
        return .static(.ds.item.socialSecurity.outlined, backgroundColor: backgroundColor)
    }

    public var icon: VaultItemIcon {
        return .static(.ds.item.socialSecurity.outlined, backgroundColor: backgroundColor)
    }

    public static var addIcon: SwiftUI.Image {
        .ds.item.socialSecurity.outlined
    }

    public var backgroundColor: SwiftUI.Color? {
        switch country?.code {
        case "FR":
            return Color(asset: Asset.socialSecurityInformationFR)
        case "GB":
            return Color(asset: Asset.socialSecurityInformationGB)
        case "US":
            return Color(asset: Asset.socialSecurityInformationUS)
        default:
            return nil
        }
    }
}
