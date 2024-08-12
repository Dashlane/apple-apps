import Foundation

public struct CustomAPIClient: Sendable {
  public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
  }

  let engine: APIClientEngine
  let signer: RequestSigner?

  public func perform<Body: Encodable, Response: Decodable>(
    _ method: HTTPMethod,
    to endpoint: Endpoint,
    body: Body,
    timeout: TimeInterval?
  ) async throws -> Response {
    if method == .post {
      return try await engine.post(endpoint, body: body, timeout: timeout, signer: signer)
    } else {
      return try await engine.get(endpoint, timeout: timeout, signer: signer)
    }
  }
}

public protocol CustomAPIClientProvider {
  var custom: CustomAPIClient { get }
}

extension AppAPIClient: CustomAPIClientProvider {
  public var custom: CustomAPIClient {
    .init(engine: engine, signer: signer)
  }
}

extension UserDeviceAPIClient: CustomAPIClientProvider {
  public var custom: CustomAPIClient {
    .init(engine: engine, signer: signer)
  }
}
