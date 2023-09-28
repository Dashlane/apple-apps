import Foundation
import DashTypes

public typealias BreachesData = (revision: Int, breaches: Set<Breach>)

public class BreachesFetcher {

    private let webservice: LegacyWebService
    private let log: Logger

    init(webservice: LegacyWebService, logger: Logger) {
        self.webservice = webservice
        self.log = logger
    }

    deinit {
        log.debug("deinit")
    }

        struct BreachesResult {
        let breaches: Set<Breach>
        let revision: Int
        let delta: DeltaUpdateBreaches
    }

            internal func fetchBreaches(existingBreaches: Set<StoredBreach>, userCredentials: [SecurityDashboardCredential], latestRevision: Int?) async -> BreachesResult {
        let breachesData = await self.publicBreaches(accounts: userCredentials, latestRevision: latestRevision)
        let delta = BreachesService.treat(Set(breachesData.breaches.compactMap(StoredBreach.init)), comparingAgainst: existingBreaches, using: userCredentials)
        return BreachesResult(breaches: breachesData.breaches,
                              revision: breachesData.revision,
                              delta: delta)
    }

            private func publicBreaches(accounts: [SecurityDashboardCredential], latestRevision: Int?) async -> BreachesData {
        log.debug("Starting to fetch public breaches")
        let revision = latestRevision ?? 0
                let breachService = BreachesFetcherGroup(revision: revision, webservice: webservice)
        let breachesManagerGroup = BreachesManagerGroup(service: breachService)
        guard let fetchedBreaches = try? await breachesManagerGroup.fetchBreaches() else {
            self.log.debug("Failed to fetch breaches, return the latest revision available and no breaches.")
            return (revision, [])
        }

        var (lastRevisionFound, breaches) = [fetchedBreaches].filterRevisionAndValidPublicBreaches()

                let lastRevision = max(revision, lastRevisionFound)

        breaches = breaches
                        .filter({ BreachesFilter.is($0, containedIn: accounts) })
                        .filter({ BreachesFilter.is($0, newerThanPasswordIn: accounts) })

                        guard latestRevision != nil else {
            self.log.debug("Finished to fetch public breaches, no revision was set so we return an empty set")
            return (lastRevision, [])
        }

        self.log.debug("Finished to fetch public breaches")
        return (lastRevision, breaches)
    }

        struct LeaksResult {
        let lastUpdateDate: TimeInterval
        let delta: DeltaUpdateBreaches
    }

        internal func fetchDataLeaks(existingBreaches: Set<StoredBreach>, decryptor: DataLeakInformationDataDecryptor?, userCredentials: [SecurityDashboardCredential], lastUpdateDate: TimeInterval?) async throws -> LeaksResult {

        let service = DataLeakMonitoringService(webservice: webservice)
        let endpointToCall = decryptor != nil ? service.leaksWithPlaintextData : service.leaks

        let result = try await endpointToCall(lastUpdateDate)
        assert(!Thread.isMainThread)
                let storedBreaches = result.leaks.compactMap(StoredBreach.init)

                let breachesIncludingDecipheredData = Self.decipheredBreaches(storedBreaches: storedBreaches, decryptor: decryptor, response: result)

        let delta = BreachesService.treat(Set(breachesIncludingDecipheredData), comparingAgainst: existingBreaches, using: userCredentials)
        return LeaksResult(lastUpdateDate: result.lastUpdateDate, delta: delta)
    }

                public static func decipheredBreaches(storedBreaches: [StoredBreach], decryptor: DataLeakInformationDataDecryptor?, response: DataLeakMonitoringLeaksResponse) -> [StoredBreach] {
                guard let details = response.details else {
            return storedBreaches
        }

        guard let cipheredKey = Data(base64Encoded: details.cipheredKey) else {
            assertionFailure("Cannot transform cipheredKey.")
            return storedBreaches
        }

        guard let cipheredInfo = Data(base64Encoded: details.cipheredInfo) else {
            assertionFailure("Cannot transform cipheredInfo.")
            return storedBreaches
        }

        guard let decryptor = decryptor,
            let decrypted = decryptor.decrypt(data: cipheredInfo,
                                              using: cipheredKey)
            else {
                assertionFailure("Could not decrypt information")
                return storedBreaches
        }

        guard let infos = try? JSONDecoder().decode([DataLeakInfo].self, from: decrypted) else {
            assertionFailure("Cannot decode cipheredInfo.")
            return storedBreaches
        }

        let updatedStoredBreaches = storedBreaches.map { (storedBreach) -> StoredBreach in
                        guard let info = infos.first(where: { $0.breachId == storedBreach.breach.id }) else {
                return storedBreach
            }
            return storedBreach.updated(with: info)
        }

        return updatedStoredBreaches
    }
}
