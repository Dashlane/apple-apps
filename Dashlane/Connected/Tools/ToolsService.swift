import Combine
import CoreFeature
import CorePremium
import CoreTypes
import Foundation
import SwiftTreats

public protocol ToolsServiceProtocol {
  func availableNavigationToolItems() -> [ToolsItem]
  func displayableTools() -> any Publisher<[ToolInfo], Never>
}

struct ToolsService: ToolsServiceProtocol {
  private let featureService: FeatureServiceProtocol
  private let capabilityService: CapabilityServiceProtocol

  init(
    featureService: FeatureServiceProtocol,
    capabilityService: CapabilityServiceProtocol
  ) {
    self.featureService = featureService
    self.capabilityService = capabilityService
  }

  func availableNavigationToolItems() -> [ToolsItem] {
    return ToolsItem.allCases.filter {
      isAvailable($0)
    }
  }

  private func isAvailable(_ item: ToolsItem) -> Bool {
    switch item {
    case .passwordGenerator:
      return Device.is(.pad, .mac, .vision)
    case .identityDashboard:
      return true
    case .secureWifi:
      return true
    case .multiDevices:
      return true
    case .contacts:
      return !Device.is(.pad, .mac, .vision)
    case .darkWebMonitoring:
      return true
    case .authenticator:
      return featureService.isEnabled(.authenticatorTool)
    case .collections:
      return !Device.is(.pad, .mac, .vision)
    }
  }

  func displayableTools() -> any Publisher<[ToolInfo], Never> {
    let toolItems = availableNavigationToolItems()
    return
      capabilityService
      .capabilitiesPublisher()
      .map { capabilities -> [ToolInfo] in
        toolItems.compactMap { toolItem -> ToolInfo? in
          if let capabilityKey = toolItem.capabilityKey {
            if capabilityKey == .secureWiFi,
              capabilities[.secureWiFi]?.info?.reason == .isUnpaidFamilyMember
            {
              return nil
            } else {
              let status = capabilities[capabilityKey]?.status ?? .unavailable
              return ToolInfo(item: toolItem, status: status)
            }

          } else {
            return ToolInfo(item: toolItem)
          }
        }
      }
      .receive(on: DispatchQueue.main)
  }
}

extension ToolsItem {
  var capabilityKey: CapabilityKey? {
    switch self {
    case .secureWifi:
      return .secureWiFi
    case .darkWebMonitoring:
      return .dataLeak
    default:
      return nil
    }
  }
}

extension ToolsServiceProtocol where Self == ToolsService {
  static func mock(capabilities: [Status.Capabilities], features: [ControlledFeature] = [])
    -> ToolsService
  {
    return .init(featureService: .mock(features: features), capabilityService: .mock(capabilities))
  }
}
