import Foundation
import DashlaneAPI

extension FeatureService {
        func refreshLoadedFlips(withServerEnabledFlips enabledFlips: Set<String>, andFlipsThatChanged updatedFlips: Set<String>) {
        let refreshableFeaturesThatHaveBeenUpdated = updatedFlips
            .compactMap(ControlledFeature.init)
            .filter { $0.updateMode == .perFlipRefresh }

                for feature in refreshableFeaturesThatHaveBeenUpdated {
            if enabledFlips.contains(feature.rawValue) {
                                features.insert(feature)
            } else {
                                features.remove(feature)
            }
        }
    }

            public func refreshFlips(isInitialFetch: Bool = false) async throws {

        let currentlyLoaded = !isInitialFetch ? features.map { $0.rawValue } : []

        logger.debug("Start to refresh feature flips, previously loaded flips [\(currentlyLoaded)]")

        let controlledFeatures = Set(ControlledFeature.allCases.map { $0.rawValue })
                let serverEnabledFlips = try await fetchEnabledFlips(includedIn: controlledFeatures)
                let updatedFlips = Set(currentlyLoaded).symmetricDifference(serverEnabledFlips)

        logger.debug("Flips enabled server side [\(serverEnabledFlips)]")
        logger.debug("Flips that changed since the last call [\(updatedFlips)]")

        store(serverEnabledFlips)

        if isInitialFetch {
            self.features = Set(serverEnabledFlips.compactMap { ControlledFeature.init(rawValue: $0) })
        } else {
            self.refreshLoadedFlips(withServerEnabledFlips: serverEnabledFlips, andFlipsThatChanged: updatedFlips)
        }
    }

                internal func fetchEnabledFlips(includedIn controlledFlips: Set<String>) async throws -> Set<String> {
                let response = try await apiClient.getAndEvaluateForUser(features: ControlledFeature.allCases.map { $0.rawValue })

                let flipHandledThatAreEnabledByServer = controlledFlips.intersection(response.enabledFeatures)

                return flipHandledThatAreEnabledByServer
    }
}
