import Foundation

#if canImport(CryptoKit)
  import CryptoKit
#elseif canImport(Crypto)
  import Crypto
#endif
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension URLRequest {
  struct CanonicalRequest {
    let headers: String
    let request: String
  }

  static var headersToIgnore = [
    "origin",
    "content-length",
    "content-encoding",
    "authorization",
    "user-agent",
    "connection",
    "cf-access-client-secret",
    "cf-access-client-id",
  ]

  func canonicalizedRequest() throws -> CanonicalRequest {
    guard let url = self.url else { throw SignatureError.invalidURL }
    let hashedPayload = SHA256.hash(data: httpBody ?? Data()).hexEncodedString()
    let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
    let headers =
      allHTTPHeaderFields?.filter { return !Self.headersToIgnore.contains($0.key.lowercased()) }
      ?? [:]
    let encodedURI = url.path.components(separatedBy: "/").map(URLRequest.encode).joined(
      separator: "/")
    let signedHeaders = self.signedHeaders(headers: headers)
    let canonicalRequest = [
      self.httpMethod ?? "GET",
      encodedURI,
      canonicalQueryString(queryItems: queryItems),
      canonicalHeaders(headers: headers),
      signedHeaders,
      hashedPayload,
    ].joined(separator: "\n")
    return CanonicalRequest(headers: signedHeaders, request: canonicalRequest)
  }

  static func encode(uri: String) -> String {
    let awsURIEncodingAllowedChars = CharacterSet.alphanumerics.union(
      CharacterSet(charactersIn: "-._~"))
    return uri.addingPercentEncoding(withAllowedCharacters: awsURIEncodingAllowedChars) ?? ""
  }

  private func canonicalHeaders(headers: [String: String]) -> String {
    return headers.map { key, value in
      return key.lowercased() + ":" + value.trimmingCharacters(in: .whitespacesAndNewlines)
    }.sorted()
      .joined(separator: "\n") + "\n"
  }

  private func canonicalQueryString(queryItems: [URLQueryItem]) -> String {
    return queryItems.sorted { $0.name < $1.name }
      .map { URLRequest.encode(uri: $0.name) + "=" + URLRequest.encode(uri: $0.value ?? "") }
      .joined(separator: "&")
  }

  private func signedHeaders(headers: [String: String]) -> String {
    return headers.keys
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .map { $0.lowercased() }
      .sorted()
      .joined(separator: ";")
  }
}
