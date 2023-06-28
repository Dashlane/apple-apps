import Foundation
import DashTypes
import Combine

public enum KilledFeature: String, Codable, CaseIterable {
    case disableAutofill
}

public protocol KillSwitchServiceProtocol {
        var killedFeatures: CurrentValueSubject<[KilledFeature], Never> { get }
}

public extension KillSwitchServiceProtocol {
    func isDisabled(_ feature: KilledFeature) -> Bool {
        return killedFeatures.value.contains(feature)
    }
}

public class KillSwitchService: KillSwitchServiceProtocol {

    public let killedFeatures = CurrentValueSubject<[KilledFeature], Never>([])

        private var nextCallTimer: Timer?
    private let callInterval: TimeInterval

    private let apiClient: DeprecatedCustomAPIClient
    private let logger: Logger

    public init(callInterval: TimeInterval = .oneHour,
                apiClient: DeprecatedCustomAPIClient,
                logger: Logger) {
        self.callInterval = callInterval
        self.apiClient = apiClient
        self.logger = logger
        refreshKilledFeatures()
    }

    func refreshKilledFeatures() {
        let features = KilledFeature.allCases.map({ $0.rawValue })
        apiClient.sendRequest(to: "/v1/killswitch/GetKillSwitches",
                               using: .post,
                               input: KillSwitchInput(requestedKillswitches: features)) { (result: Result<KillSwitchResponse, Error>) in
            switch result {
            case let .success(response):
                self.killedFeatures.value = response.killedFeatures
                if !response.killedFeatures.isEmpty {
                    self.logger.warning("Disabled \(response.killedFeatures)")
                }
            case let .failure(error):
                self.logger.error(error.localizedDescription)
            }
            DispatchQueue.main.async {
                self.scheduleNextCall()
            }
        }
    }

    private func scheduleNextCall() {
        self.nextCallTimer = Timer.scheduledTimer(withTimeInterval: callInterval, repeats: false, block: { _ in
            self.refreshKilledFeatures()
        })
    }
}

private struct KillSwitchInput: Encodable {
    let requestedKillswitches: [String]
}

struct KillSwitchResponse: Decodable {
    let killedFeatures: [KilledFeature]

    init(killedFeatures: [KilledFeature]) {
        self.killedFeatures = killedFeatures
    }

    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var killedFeaturesStatus = [KilledFeature: Bool]()

        for key in container.allKeys {
            guard let dynamicKey = DynamicCodingKeys(stringValue: key.stringValue) else { break }
            guard let feature = KilledFeature(rawValue: key.stringValue) else { break }
            let disabled = try container.decode(Bool.self, forKey: dynamicKey)
            killedFeaturesStatus[feature] = disabled
        }
                self.killedFeatures = killedFeaturesStatus.filter({ $0.value == true }).map({ $0.key })
    }
}

public extension TimeInterval {
    static var oneHour: TimeInterval = 60 * 60
}
