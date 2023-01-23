import Foundation
import UIKit
import DashlaneAppKit
import SwiftTreats

public enum ToolsItem: String, CaseIterable, Hashable, TabElement {
    case identityDashboard
    case darkWebMonitoring
    case secureWifi
    case passwordGenerator = "PasswordGenerator"
    case multiDevices = "MobileToDesktop"
    case contacts
    case authenticator

    var tabBarImage: NavigationImageSet {
        .init(image: image,
              selectedImage: image)
    }

    var image: ImageAsset {
        switch self {
        case .passwordGenerator:
            return FiberAsset.toolsPasswordGenerator
        case .multiDevices:
            return FiberAsset.toolsNewDeviceConnector
        case .identityDashboard:
            return FiberAsset.toolsIdentityDashboard
        case .secureWifi:
            return FiberAsset.toolsVpn
        case .darkWebMonitoring:
            return FiberAsset.toolsDarkWeb
        case .contacts:
            return FiberAsset.toolsSharing
        case .authenticator:
            return FiberAsset.pictoAuthenticator
        }
    }

    var sidebarImage: NavigationImageSet {
        switch self {
        case .passwordGenerator:
            return .init(image: FiberAsset.sidebarToolsPasswordgenerator,
                         selectedImage: FiberAsset.sidebarToolsPasswordgeneratorSelected)
        case .multiDevices:
            return .init(image: FiberAsset.sidebarToolsNewdevice,
                         selectedImage: FiberAsset.sidebarToolsNewdeviceSelected)
        case .identityDashboard:
            return .init(image: FiberAsset.sidebarToolsIdentitydashboard,
                         selectedImage: FiberAsset.sidebarToolsIdentitydashboardSelected)
        case .secureWifi:
            return .init(image: FiberAsset.sidebarToolsVpn,
                         selectedImage: FiberAsset.sidebarToolsVpnSelected)
        case .darkWebMonitoring:
            return .init(image: FiberAsset.sidebarToolsDarkWebMonitoring,
                         selectedImage: FiberAsset.sidebarToolsDarkWebMonitoringSelected)
        case .contacts:
            return .init(image: FiberAsset.sidebarContacts,
                         selectedImage: FiberAsset.sidebarContactsSelected)
        case .authenticator:
            return .init(image: FiberAsset.pictoAuthenticator,
                         selectedImage: FiberAsset.pictoAuthenticator)
        }
    }

    var title: String {
        switch self {
        case .passwordGenerator:
            return L10n.Localizable.mainMenuPasswordGenerator
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
        }
    }
}
