import CoreTypes
import DashlaneAPI
import Foundation
import SwiftTreats

typealias GetBreachesResponse = UserDeviceAPIClient.Breaches.GetBreach.Response

class BreachesFetcherGroup {

  let userDeviceAPIClient: UserDeviceAPIClient
  let revision: Int

  public init(
    revision: Int = 0,
    userDeviceAPIClient: UserDeviceAPIClient
  ) {
    self.revision = revision
    self.userDeviceAPIClient = userDeviceAPIClient
  }

  private func fetch(info: GetBreachesResponse) async throws -> Set<PublicBreach> {
    guard let files = info.filesToDownload else {
      return []
    }
    return await withTaskGroup(of: Set<PublicBreach>.self) { group in
      for rawURL in files {
        guard let url = URL(string: rawURL) else { continue }
        group.addTask {
          let fetcher = BreachesEntriesServiceFetcher(url: url)
          return (try? await fetcher.fetch()) ?? []
        }
      }
      var resultsList = [Set<PublicBreach>]()
      for await result in group {
        resultsList.append(result)
      }
      resultsList.append(Set(info.latestBreaches))
      resultsList = resultsList.reversed()

      let breaches =
        resultsList
        .filter { !$0.isEmpty }
        .flatMap { $0 }

      return Set(breaches)
    }
  }

  public func start() async throws -> PublicBreachesData {
    let breachesInfo = try await userDeviceAPIClient.breaches.getBreach(revision: self.revision)

    guard let filesToDownload = breachesInfo.filesToDownload, !filesToDownload.isEmpty else {
      return (breachesInfo.revision, Set(breachesInfo.latestBreaches))
    }

    let fetchedBreaches = try await self.fetch(info: breachesInfo)
    return (breachesInfo.revision, Set(fetchedBreaches))
  }
}
