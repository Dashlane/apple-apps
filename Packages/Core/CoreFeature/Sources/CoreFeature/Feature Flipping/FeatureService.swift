import Foundation
import DashTypes
import CoreNetworking
import CoreSession
import Combine
import SwiftTreats
import DashlaneAPI

public class FeatureService: FeatureServiceProtocol {
    private let refreshInterval: TimeInterval
    internal let apiClient: UserDeviceAPIClient.Features
    internal let login: String
    internal let logger: Logger
    private let storage: FeatureFlipServiceStorage

    @Atomic
    public internal(set) var features = Set<ControlledFeature>()

    private var refreshTask: Task<Void, Error>?

    public init(session: Session,
                apiClient: UserDeviceAPIClient.Features,
                featureStorage: FeatureFlipServiceStorage? = nil,
                refreshInterval: TimeInterval = 15 * 60, 
                logger: Logger) async {
        self.apiClient = apiClient
        self.login = session.login.email
        if let featureStorage = featureStorage {
            self.storage = featureStorage
        } else {
            self.storage = FeatureStorage(session: session)
        }
        self.refreshInterval = refreshInterval
        self.logger = logger

        let timerTrigger = Timer.publish(every: refreshInterval, on: .main, in: .default)
            .autoconnect()
            .map { _ in Void() }
        if !storage.hasStoredData() {
            do {
                try await refreshFlips(isInitialFetch: true)
            } catch {
                logger.error("cannot retrieve feature flips", error: error)
            }
            startRefreshingFlips(using: timerTrigger.values)

        } else {
            retrieveStoredFlips()
            startRefreshingFlips(using: timerTrigger.prepend(Void()).values)
        }
    }

        public func isEnabled(_ feature: ControlledFeature) -> Bool {
        return enabledFeatures().contains(feature)
    }

    public func enabledFeatures() -> Set<ControlledFeature> {
#if DEBUG
        features.union(ControlledFeature.forcedFeatureFlips)
#else
        features
#endif
    }

        internal func retrieveStoredFlips() {
        guard storage.hasStoredData() else {
            logger.info("no feature flips stored")
            return
        }
        do {
            let flipsData = try storage.retrieve()
            let rawFlips = try JSONDecoder().decode(Set<String>.self, from: flipsData)
            self.features = Set(rawFlips.compactMap { ControlledFeature(rawValue: $0) })
        } catch {
            logger.fatal("cannot retrieve feature flips", error: error)
        }
    }

    internal func store(_ serverEnabledFlips: Set<String>) {
        do {
            let encoded = try JSONEncoder().encode(serverEnabledFlips)
            try storage.store(encoded)
        } catch {
            logger.fatal("cannot persist feature flips", error: error)
        }
    }

    internal func startRefreshingFlips<T: AsyncSequence>(using sequence: T) {
        refreshTask = Task {
            for try await _ in sequence {
                do {
                    try await refreshFlips()
                } catch {
                    logger.error("Fail to refresh flip", error: error)
                }
            }
        }
    }

    deinit {
        refreshTask?.cancel()
    }
}

public extension FeatureServiceProtocol where Self == MockFeatureService {
    static func mock(features: [ControlledFeature] = []) -> MockFeatureService {
        return MockFeatureService(features: features)
    }
}

public class MockFeatureService: FeatureServiceProtocol {
    var features: [ControlledFeature]

    public init(features: [ControlledFeature] = []) {
        self.features = features
    }

    public func isEnabled(_ feature: ControlledFeature) -> Bool {
        features.contains(feature)
    }

    public func enabledFeatures() -> Set<ControlledFeature> {
        return Set(features)
    }
}
