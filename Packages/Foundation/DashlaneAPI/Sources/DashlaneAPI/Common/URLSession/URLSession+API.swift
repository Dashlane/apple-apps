import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct APISuccessResponse<D: Decodable>: Decodable {
  let requestId: String
  public let data: D
}

extension APISuccessResponse: Encodable where D: Encodable {}

extension URLSession {
  func response<Response: Decodable, Error: Swift.Error & Codable>(
    from urlRequest: URLRequest, using decoder: JSONDecoder, errorType: Error.Type
  ) async throws -> Response {
    let (data, response) = try await self.data(for: urlRequest)

    guard let urlResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    switch urlResponse.statusCode {
    case ~200..<300:
      return try decoder.decode(APISuccessResponse<Response>.self, from: data).data
    default:
      throw try decoder.decode(errorType, from: data)
    }
  }
}
