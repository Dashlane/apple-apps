import Foundation
import UIKit
import DashlaneAppKit
import SwiftTreats
import DesignSystem
import SwiftUI
import CoreLocalization

public enum ToolsItem: String, CaseIterable, Hashable, TabElement, Identifiable {

    case identityDashboard
    case darkWebMonitoring
    case secureWifi
    case passwordGenerator = "PasswordGenerator"
    case multiDevices = "MobileToDesktop"
    case contacts
    case authenticator
    case collections

    public var id: String {
        return rawValue
    }

    var tabBarImage: NavigationImageSet {
        .init(image: image,
              selectedImage: image)
    }

    var image: UIImage {
        switch self {
        case .passwordGenerator:
            return .ds.feature.passwordGenerator.outlined
        case .multiDevices:
            return .ds.laptopCheckmark.outlined
        case .identityDashboard:
            return .ds.feature.passwordHealth.outlined
        case .secureWifi:
            return .ds.feature.vpn.outlined
        case .darkWebMonitoring:
            return .ds.feature.darkWebMonitoring.outlined
        case .contacts:
            return .ds.shared.outlined
        case .authenticator:
            return .ds.feature.authenticator.outlined
        case .collections:
            return .ds.folder.outlined
        }
    }

    public var icon: SwiftUI.Image {
        switch self {
        case .passwordGenerator:
            return .ds.feature.passwordGenerator.outlined
        case .multiDevices:
            return .ds.laptopCheckmark.outlined
        case .identityDashboard:
            return .ds.feature.passwordHealth.outlined
        case .secureWifi:
            return .ds.feature.vpn.outlined
        case .darkWebMonitoring:
            return .ds.feature.darkWebMonitoring.outlined
        case .contacts:
            return .ds.shared.outlined
        case .authenticator:
            return .ds.feature.authenticator.outlined
        case .collections:
            return .ds.folder.outlined
        }
    }

    public var selectedIcon: SwiftUI.Image {
        switch self {
        case .passwordGenerator:
            return .ds.feature.passwordGenerator.filled
        case .multiDevices:
            return .ds.laptopCheckmark.filled
        case .identityDashboard:
            return .ds.feature.passwordHealth.outlined
        case .secureWifi:
            return .ds.feature.vpn.filled
        case .darkWebMonitoring:
            return .ds.feature.darkWebMonitoring.outlined
        case .contacts:
            return .ds.shared.filled
        case .authenticator:
            return .ds.feature.authenticator.filled
        case .collections:
            return .ds.folder.filled
        }
    }

    var title: String {
        switch self {
        case .passwordGenerator:
            return CoreLocalization.L10n.Core.mainMenuPasswordGenerator
        case .multiDevices:
            return L10n.Localizable.kwMultiDevices
        case .identityDashboard:
            return L10n.Localizable.identityDashboardTitle
        case .secureWifi:
            return L10n.Localizable.secureWifiToolsTitle
        case .darkWebMonitoring:
            return L10n.Localizable.dataleakNotificationTitle
        case .contacts:
            return L10n.Localizable.tabContactsTitle
        case .authenticator:
            return L10n.Localizable.otpToolName
        case .collections:
            return CoreLocalization.L10n.Core.KWVaultItem.Collections.toolsTitle
        }
    }
}
