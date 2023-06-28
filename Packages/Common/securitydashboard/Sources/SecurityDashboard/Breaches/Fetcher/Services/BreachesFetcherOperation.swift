import Foundation
import DashTypes
import SwiftTreats

class BreachesFetcherGroup {

    let webservice: LegacyWebService
    let revision: Int

                        public init(revision: Int = 0, webservice: LegacyWebService) {
        self.revision = revision
        self.webservice = webservice
    }

    private func fetch(info: BreachQueryInfo) async throws -> Set<Breach> {
        return await withTaskGroup(of: Set<Breach>.self) { group in
            for rawURL in info.filesToDownload {
                guard let url = URL(string: rawURL) else { continue }
                group.addTask {
                    let fetcher = BreachesEntriesServiceFetcher(url: url)
                    return (try? await fetcher.fetch()) ?? []
                }
            }
            var resultsList = [Set<Breach>]()
            for await result in group {
                resultsList.append(result)
            }
                        var breachesLists = resultsList.filter({ !$0.isEmpty })
            breachesLists.append(info.latest)
            breachesLists = breachesLists.reversed() 

                        let breaches = Set(breachesLists.flatMap({ $0 }))

            return breaches
        }
    }

    public func start() async throws -> BreachesData {
        let resource = BreachesInfoService.resource(forRevision: self.revision)
        let breachQueryInfo = try await resource.load(on: webservice)
        guard breachQueryInfo.filesToDownload.count > 0 else {
                        return (breachQueryInfo.revision, breachQueryInfo.latest)
        }

        let fetchedBreaches = try await self.fetch(info: breachQueryInfo)
        return (breachQueryInfo.revision, fetchedBreaches)
    }
}
