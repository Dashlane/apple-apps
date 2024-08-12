import Combine
import DashTypes
import DashlaneAPI
import Foundation

public enum KilledFeature: String, Codable, CaseIterable {
  case disableAutofill
}

public protocol KillSwitchServiceProtocol {
  var killedFeatures: CurrentValueSubject<[KilledFeature], Never> { get }
}

extension KillSwitchServiceProtocol {
  public func isDisabled(_ feature: KilledFeature) -> Bool {
    return killedFeatures.value.contains(feature)
  }
}

public class KillSwitchService: KillSwitchServiceProtocol {

  public let killedFeatures = CurrentValueSubject<[KilledFeature], Never>([])

  private var nextCallTimer: Timer?
  private let callInterval: TimeInterval

  private let apiClient: AppAPIClient
  private let logger: Logger

  public init(
    callInterval: TimeInterval = .oneHour,
    apiClient: AppAPIClient,
    logger: Logger
  ) {
    self.callInterval = callInterval
    self.apiClient = apiClient
    self.logger = logger
    Task {
      await refreshKilledFeatures()
    }
  }

  func refreshKilledFeatures() async {
    let features = KilledFeature.allCases.map({ $0.rawValue })
    do {
      let result = try await apiClient.killswitch.getKillSwitches(requestedKillswitches: features)
      let killedFeatures = KilledFeature.allCases.filter {
        result[$0.rawValue]?.boolean == true
      }
      self.killedFeatures.value = killedFeatures

      if !killedFeatures.isEmpty {
        self.logger.warning("Disabled \(killedFeatures)")
      }
    } catch {
      self.logger.error(error.localizedDescription)
    }
    self.scheduleNextCall()
  }

  private func scheduleNextCall() {
    DispatchQueue.main.async {
      self.nextCallTimer = Timer.scheduledTimer(
        withTimeInterval: self.callInterval, repeats: false,
        block: { _ in
          Task {
            await self.refreshKilledFeatures()
          }
        })
    }
  }
}

extension TimeInterval {
  public static var oneHour: TimeInterval = 60 * 60
}
