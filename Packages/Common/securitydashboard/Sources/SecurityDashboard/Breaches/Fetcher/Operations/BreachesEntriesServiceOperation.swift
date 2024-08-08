import DashTypes
import Foundation

final class BreachesEntriesServiceFetcher {

  enum ErrorType: Error {
    case downloadError(error: Error)
    case processingError
  }

  let url: URL

  private let urlSession = URLSession(configuration: .default)

  init(url: URL) {
    self.url = url
  }

  func fetch() async throws -> Set<PublicBreach> {
    let request = URLRequest(url: url)

    let dataAndResponse = try await urlSession.data(for: request)
    let data = dataAndResponse.0
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    guard var breachesQuery = try? decoder.decode(FileBreachesResponse.self, from: data) else {
      throw ErrorType.processingError
    }
    breachesQuery.breaches = Set(data.breaches.reversed())
    return breachesQuery.breaches
  }
}

extension Data {

  fileprivate var breaches: [PublicBreach] {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = .secondsSince1970
    var breaches = [PublicBreach]()
    if let json = (try? JSONSerialization.jsonObject(with: self, options: [])) as? [String: Any],
      let breachesArray = json["breaches"] as? [[String: Any]]
    {
      for breachDictionary in breachesArray {

        guard
          let originalJsonData = try? JSONSerialization.data(
            withJSONObject: breachDictionary, options: .prettyPrinted),
          let newbreach = try? jsonDecoder.decode(PublicBreach.self, from: originalJsonData)
        else {
          continue
        }
        breaches.append(newbreach)
      }
    }
    return breaches
  }
}
