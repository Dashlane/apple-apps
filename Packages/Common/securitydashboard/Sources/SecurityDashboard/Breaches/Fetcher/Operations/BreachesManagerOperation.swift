import Foundation

final class BreachesManagerGroup {

  let service: BreachesFetcherGroup

  init(service: BreachesFetcherGroup) {
    self.service = service
  }

  func fetchBreaches() async throws -> PublicBreachesData {
    let data = try await service.start()
    return (data.revision, data.breaches)
  }
}
