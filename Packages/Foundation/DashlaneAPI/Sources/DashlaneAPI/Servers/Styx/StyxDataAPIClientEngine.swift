import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol StyxDataAPIClientEngine {
  func post(_ endpoint: Endpoint, data: Data, signer: RequestSigner, isTestEnvironment: Bool)
    async throws
}

public struct StyxError: Error {
  public let message: String?
  public let statusCode: Int
}

struct StyxResponse: Codable {
  let success: Bool
  let error: String?
}

struct StyxDataAPIClientEngineImpl: StyxDataAPIClientEngine {
  let session: URLSession
  let apiClientEngine: APIClientEngine
  let decoder = JSONDecoder()
  let additionalHeaders: [String: String]
  let apiURL: URL

  public init(
    apiURL: URL,
    apiClientEngine: APIClientEngine,
    additionalHeaders: [String: String],
    session: URLSession = URLSession(configuration: .ephemeral)
  ) {
    self.apiURL = apiURL
    self.apiClientEngine = apiClientEngine
    self.additionalHeaders = additionalHeaders
    self.session = session
  }

  func post(_ endpoint: Endpoint, data: Data, signer: RequestSigner, isTestEnvironment: Bool)
    async throws
  {
    let url = apiURL.appendingPathComponent(endpoint)

    var request = URLRequest(
      url: url,
      cachePolicy: .reloadIgnoringLocalCacheData,
      timeoutInterval: 100)
    request.setValue(url.hostWithPort, forHTTPHeaderField: "Host")
    request.setHeaders(additionalHeaders)
    request.updateBody(data)

    try await request.sign(with: signer)

    if isTestEnvironment {
      request.setValue("1", forHTTPHeaderField: "X-DL-TEST")
    }

    try await session.styxResponse(from: request, using: decoder)
  }
}

extension URLSession {
  fileprivate func styxResponse(from urlRequest: URLRequest, using decoder: JSONDecoder)
    async throws
  {
    let (data, response) = try await self.data(for: urlRequest)

    guard let urlResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }
    let decodedResponse = try decoder.decode(StyxResponse.self, from: data)

    switch urlResponse.statusCode {
    case ~200..<300 where decodedResponse.success == true:
      return
    default:
      throw StyxError(message: decodedResponse.error, statusCode: urlResponse.statusCode)
    }
  }
}
