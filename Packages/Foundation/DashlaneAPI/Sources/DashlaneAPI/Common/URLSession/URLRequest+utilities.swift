import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension URLRequest {
  static let dataCompressionThreshold = 860

  mutating func setHeaders(_ headers: [String: String]) {
    for header in headers {
      setValue(header.value, forHTTPHeaderField: header.key)
    }
  }

  mutating func updateBody<Content: Encodable>(_ content: Content, using encoder: JSONEncoder)
    throws
  {
    httpMethod = "POST"
    let data = try encoder.encode(content)
    updateBody(data)
  }

  mutating func updateBody(_ data: Data) {
    httpMethod = "POST"
    setValue("application/json", forHTTPHeaderField: "content-type")
    #if canImport(zlib)
      if data.count > Self.dataCompressionThreshold {
        httpBody = data.gzipCompressed()
        setValue("gzip", forHTTPHeaderField: "Content-Encoding")
      } else {
        httpBody = data
      }
    #else
      httpBody = data
    #endif

    setValue(String(httpBody?.count ?? 0), forHTTPHeaderField: "Content-Length")
  }
}

extension URL {
  var hostWithPort: String? {
    guard let host = host, let port = port else { return self.host }
    return "\(host):\(port)"
  }
}
