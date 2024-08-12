import Foundation

public struct CharonDataAPIClient {
  public static let defaultServerURL: URL = URL(string: "_")!

  let apiURL: URL
  let engine: CharonDataAPIClientEngine
  let signer: RequestSigner
  let encoder = JSONEncoder()

  public typealias Identifier = String

  struct Endpoints {
    public static let retrieve = "/v1/retrieve"
    public static let clear = "/v1/clear"
    public static let validate = "/v1/validate"
    public static let analyticsId = "/v1/analytics-ids"
  }

  struct Parameters {
    public static let userId = "user_id"
    public static let deviceId = "device_id"
    public static let installationId = "installation_id"

    public static let category = "category"
    public static let login = "login"
    public static let name = "name"
    public static let platform = "platform"
    public static let secondsBack = "seconds_back"
  }

  public init(
    apiURL: URL = Self.defaultServerURL, credentials: AppCredentials, appAPIClient: AppAPIClient
  ) {
    self.apiURL = apiURL
    self.signer = RequestSigner(
      appCredentials: credentials,
      userCredentials: nil,
      timeshiftProvider: appAPIClient.timeshiftProvider)
    self.encoder.keyEncodingStrategy = .convertToSnakeCase
    self.engine = CharonDataAPIClientEngineImpl(
      apiURL: apiURL,
      apiClientEngine: appAPIClient.engine,
      signer: signer, additionalHeaders: appAPIClient.configuration.additionalHeaders)
  }

  public func clearEvents(with identifier: String, idType: String?) async throws {
    let url = apiURL.appendingPathComponent(Endpoints.clear)
      .appending(idType ?? Parameters.installationId, value: identifier)
      .appending(Parameters.platform, value: "IOS")
    let _: CharonDataAPIClient.CharonResponse<CharonDataAPIClient.Properties.Empty> =
      try await sendGetRequest(url: url)
    let amount = try await waitForEventsToClear(identifier: identifier)
    if amount > 0 {
      let _: CharonDataAPIClient.CharonResponse<CharonDataAPIClient.Properties.Empty> =
        try await sendGetRequest(url: url)
    }
  }

  private func waitForEventsToClear(identifier: String) async throws -> Int {
    var runCount = 0
    while try await amountOfEventsInStorage(with: identifier) > 0 && runCount < 5 {
      try await Task.sleep(nanoseconds: 1_000_000_000)

      runCount += 1
    }
    return try await amountOfEventsInStorage(with: identifier)
  }

  public func validate<T: Codable>(
    event: CharonDataAPIClient.Event<T>, with identifier: Identifier, clearAfter: Bool,
    amountOfEventsInStorageBeforeAction: Int
  ) async throws -> CharonDataAPIClient.CharonResponse<CharonDataAPIClient.Properties.Empty> {

    let url = apiURL.appendingPathComponent(Endpoints.validate)
    let body = try encoder.encode(event)

    try await waitForNumberOfEventsToIncrease(
      before: amountOfEventsInStorageBeforeAction, identifier: identifier)
    let response = try await sendPostRequest(url: url, body: body, validateSuccess: false)
    if clearAfter {
      try await clearEvents(with: identifier, idType: Parameters.installationId)
    }

    return response
  }

  public func validateAnonymous<T: Codable>(
    event: CharonDataAPIClient.Event<T>, with identifier: CharonDataAPIClient.Identifier
  ) async throws -> CharonDataAPIClient.CharonResponse<CharonDataAPIClient.Properties.Empty> {
    let url = apiURL.appendingPathComponent(Endpoints.validate)
      .appending(Parameters.category, value: "anonymous")
      .appending(Parameters.name, value: identifier)
      .appending(Parameters.secondsBack, value: "10")
      .appending(Parameters.platform, value: "IOS")

    let body = try encoder.encode(event)
    return try await sendPostRequest(url: url, body: body, validateSuccess: false)
  }

  public func validateEventIsAbsent<T: Codable>(event: CharonDataAPIClient.Event<T>) async throws
    -> CharonDataAPIClient.CharonResponse<CharonDataAPIClient.Properties.Empty>
  {
    let url = apiURL.appendingPathComponent(Endpoints.validate)
    let body = try encoder.encode(event)

    try await Task.sleep(nanoseconds: 3_000_000_000)
    return try await sendPostRequest(url: url, body: body, validateSuccess: false)
  }

  public func retrieveEvents<T: Codable>(
    with identifier: CharonDataAPIClient.Identifier, idType: String, name: String? = nil
  ) async throws -> CharonDataAPIClient.CharonResponse<T> {
    var url = apiURL.appendingPathComponent(Endpoints.retrieve)
      .appending(idType, value: identifier)

    if let name = name {
      url = url.appending(Parameters.name, value: name)
    }

    return try await sendGetRequest(url: url)
  }

  public func retrieveAnonymousEvents<T: Codable>(with identifier: CharonDataAPIClient.Identifier)
    async throws -> CharonDataAPIClient.CharonResponse<T>
  {
    let url = apiURL.appendingPathComponent(Endpoints.retrieve)
      .appending(Parameters.category, value: "anonymous")
      .appending(Parameters.name, value: identifier)
      .appending(Parameters.secondsBack, value: "10")
      .appending(Parameters.platform, value: "IOS")

    return try await sendGetRequest(url: url)
  }

  public func amountOfEventsInStorage(with identifier: CharonDataAPIClient.Identifier) async throws
    -> Int
  {
    let response: CharonDataAPIClient.CharonResponse<CharonDataAPIClient.Properties.Empty> =
      try await retrieveEvents(with: identifier, idType: Parameters.installationId)
    return response.result?.count ?? 0
  }

  private func waitForNumberOfEventsToIncrease(before: Int, identifier: String) async throws {
    var runCount = 0
    while try await amountOfEventsInStorage(with: identifier) <= before && runCount < 10 {
      try await Task.sleep(nanoseconds: 1_000_000_000)

      runCount += 1
    }
  }
}

extension AppAPIClient {
  public func makeCharonDataClient(
    apiURL: URL = CharonDataAPIClient.defaultServerURL, credentials: AppCredentials
  ) -> CharonDataAPIClient {
    CharonDataAPIClient(apiURL: apiURL, credentials: credentials, appAPIClient: self)
  }
}

extension CharonDataAPIClient {

  public func sendGetRequest<T: Codable>(url: URL) async throws
    -> CharonDataAPIClient.CharonResponse<T>
  {
    try await engine.sendGetRequest(url: url)
  }

  public func sendPostRequest(url: URL, body: Data, validateSuccess: Bool) async throws
    -> CharonDataAPIClient.CharonResponse<CharonDataAPIClient.Properties.Empty>
  {
    try await engine.sendPostRequest(url: url, body: body, validateSuccess: validateSuccess)
  }

}

extension URL {

  fileprivate func appending(_ queryItem: String, value: String?) -> URL {
    guard var urlComponents = URLComponents(string: absoluteString) else {
      return absoluteURL
    }

    var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
    let queryItem = URLQueryItem(name: queryItem, value: value)
    queryItems.append(queryItem)
    urlComponents.queryItems = queryItems
    return urlComponents.url!
  }
}
