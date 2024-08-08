import Combine
import DashlaneAPI
import Foundation

public protocol CapabilityServiceProtocol {
  typealias Capability = Status.Capabilities
  typealias Capabilities = [CapabilityKey: Capability]

  var capabilities: Capabilities { get }
  func capabilitiesPublisher() -> AnyPublisher<Capabilities, Never>

  func status(of capability: CapabilityKey) -> CapabilityStatus
  func statusPublisher(of capability: CapabilityKey) -> AnyPublisher<CapabilityStatus, Never>

  func allStatus() -> [CapabilityKey: CapabilityStatus]
  func allStatusPublisher() -> AnyPublisher<[CapabilityKey: CapabilityStatus], Never>
}

public typealias CapabilityKey = Status.Capabilities.Capability

public final class CapabilityService: CapabilityServiceProtocol {
  @Published
  public private(set) var capabilities: Capabilities = [:]

  public init(provider: some PremiumStatusProvider) {
    provider.statusPublisher
      .map { status in
        return .init(capabilities: status.capabilities)
      }
      .removeDuplicates()
      .assign(to: &$capabilities)
  }

  public func capabilitiesPublisher() -> AnyPublisher<Capabilities, Never> {
    return $capabilities.eraseToAnyPublisher()
  }

  public func status(of capability: CapabilityKey) -> CapabilityStatus {
    return capabilities[capability]?.status ?? .unavailable
  }

  public func statusPublisher(of capability: CapabilityKey) -> AnyPublisher<CapabilityStatus, Never>
  {
    return $capabilities.map {
      $0[capability]?.status ?? .unavailable
    }.eraseToAnyPublisher()
  }

  public func allStatus() -> [CapabilityKey: CapabilityStatus] {
    capabilities.mapValues(\.status)
  }

  public func allStatusPublisher() -> AnyPublisher<[CapabilityKey: CapabilityStatus], Never> {
    $capabilities.map {
      $0.mapValues(\.status)
    }.eraseToAnyPublisher()
  }
}

extension [CapabilityKey: CapabilityService.Capability] {
  init(capabilities: [Status.Capabilities]) {
    self.init(minimumCapacity: capabilities.count)
    for capability in capabilities {
      self[capability.capability] = capability
    }
  }
}

extension CapabilityServiceProtocol.Capability {
  public var status: CapabilityStatus {
    if capability == .secureWiFi {
      if !enabled, info?.reason == .inTeam {
        return .unavailable
      } else if info?.reason == .isUnpaidFamilyMember {
        return .unavailable
      }
    }

    if enabled {
      return .available()
    } else {
      return .needsUpgrade
    }
  }
}

extension CapabilityServiceProtocol where Self == CapabilityService {
  public static func mock(
    _ capabilities: [DashlaneAPI.UserDeviceAPIClient.Premium.GetPremiumStatus.Response
      .CapabilitiesElement] = []
  ) -> CapabilityService {
    let status = Status(
      b2cStatus: .init(
        statusCode: .free,
        isTrial: false,
        autoRenewal: false),
      capabilities: capabilities)

    return .init(provider: PremiumStatusProviderMock.mock(status: status))
  }
}
