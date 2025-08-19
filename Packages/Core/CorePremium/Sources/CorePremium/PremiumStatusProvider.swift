import Combine
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation

public protocol PremiumStatusProvider {
  var status: Status { get }
  var statusPublisher: AnyPublisher<Status, Never> { get }
  func refresh() async throws
}

public protocol PremiumStatusCache {
  func retrievePremiumStatus() throws -> Status
  func savePremiumStatus(_: Status) throws
}

public typealias CurrentTeam = DashlaneAPI.UserDeviceAPIClient.Premium.GetPremiumStatus.Response
  .B2bStatus.CurrentTeam

public struct Status: Codable, Equatable, Sendable {
  public typealias APIStatus = DashlaneAPI.UserDeviceAPIClient.Premium.GetPremiumStatus.Response

  public typealias Capabilities = DashlaneAPI.UserDeviceAPIClient.Premium.GetPremiumStatus.Response
    .CapabilitiesElement
  public typealias B2cStatus = DashlaneAPI.UserDeviceAPIClient.Premium.GetPremiumStatus.Response
    .B2cStatus
  public typealias B2bStatus = DashlaneAPI.UserDeviceAPIClient.Premium.GetPremiumStatus.Response
    .B2bStatus

  public let b2cStatus: B2cStatus

  public let capabilities: [Capabilities]

  public let b2bStatus: B2bStatus?

  init(apiStatus: APIStatus) {
    self.b2cStatus = apiStatus.b2cStatus
    self.capabilities = apiStatus.capabilities
    self.b2bStatus = apiStatus.b2bStatus
  }

  public init(b2cStatus: B2cStatus, capabilities: [Capabilities], b2bStatus: B2bStatus? = nil) {
    self.b2cStatus = b2cStatus
    self.capabilities = capabilities
    self.b2bStatus = b2bStatus
  }
}

public class PremiumStatusAPIProvider: PremiumStatusProvider {
  let client: UserDeviceAPIClient
  let cache: PremiumStatusCache?
  let logger: Logger
  let onStatusChange: (Status) -> Void

  @Published
  public private(set) var status: Status
  public var statusPublisher: AnyPublisher<Status, Never> {
    $status.removeDuplicates().eraseToAnyPublisher()
  }
  var refreshSubcription: AnyCancellable?

  public init(
    client: UserDeviceAPIClient,
    cache: PremiumStatusCache? = nil,
    refreshTrigger: any Publisher<Void, Never> = Just.init(Void()),
    onStatusChange: @escaping (Status) -> Void = { _ in },
    logger: Logger
  ) async throws {
    self.client = client
    self.cache = cache
    self.logger = logger
    self.onStatusChange = onStatusChange

    if let status = try? cache?.retrievePremiumStatus() {
      self.status = status
      try await refresh()
    } else {
      self.status = Status(apiStatus: try await client.premium.getPremiumStatus(timeout: 10))
      try cache?.savePremiumStatus(status)
    }

    refreshSubcription = refreshTrigger.sink { [weak self] in
      self?.refreshFromTrigger()
    }
  }

  @MainActor
  public func refresh() async throws {
    Task {
      do {
        let status = Status(apiStatus: try await client.premium.getPremiumStatus())
        guard status != self.status else {
          return
        }
        self.status = status
        onStatusChange(status)
        try cache?.savePremiumStatus(status)
      } catch {
        logger.error("Cannot refresh status", error: error)
      }
    }
  }

  private func refreshFromTrigger() {
    Task {
      try await refresh()
    }
  }
}

public class PremiumStatusFromCacheProvider: PremiumStatusProvider {
  struct NoCacheError: Error {

  }

  @Published
  public var status: Status
  public var statusPublisher: AnyPublisher<Status, Never> {
    $status.removeDuplicates().eraseToAnyPublisher()
  }

  private let cache: PremiumStatusCache

  public init(cache: PremiumStatusCache) throws {
    guard let status = try? cache.retrievePremiumStatus() else {
      throw NoCacheError()
    }
    self.cache = cache
    self.status = status
  }

  public func refresh() {
    guard let status = try? cache.retrievePremiumStatus() else {
      return
    }

    self.status = status
  }
}

extension Sequence
where
  Iterator.Element == DashlaneAPI.UserDeviceAPIClient.Premium.GetPremiumStatus.Response
    .CapabilitiesElement
{
  public subscript(
    capability: DashlaneAPI.UserDeviceAPIClient.Premium.GetPremiumStatus.Response
      .CapabilitiesElement.Capability
  ) -> DashlaneAPI.UserDeviceAPIClient.Premium.GetPremiumStatus.Response.CapabilitiesElement? {
    return self.first { $0.capability == capability }
  }
}

public class PremiumStatusProviderMock: PremiumStatusProvider {
  @Published
  public var status: Status
  init(status: Status) {
    self.status = status
  }

  public var statusPublisher: AnyPublisher<Status, Never> {
    Just(status).eraseToAnyPublisher()
  }

  public func refresh() async throws {

  }
}

extension PremiumStatusProvider where Self == PremiumStatusProviderMock {
  public static func mock(
    status: Status = Status(
      b2cStatus: .init(
        statusCode: .free,
        isTrial: false,
        autoRenewal: false),
      capabilities: [])
  ) -> PremiumStatusProviderMock {
    return PremiumStatusProviderMock(status: status)
  }
}
