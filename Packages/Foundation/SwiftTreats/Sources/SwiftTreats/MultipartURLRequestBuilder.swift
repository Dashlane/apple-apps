import Foundation
import OrderedCollections

public struct MultipartURLRequestBuilder {

  enum RequestData {
    case form(String)
    case file(Data)
  }

  private var fields = OrderedDictionary<String, RequestData>()
  private let url: URL
  internal let boundary = UUID().uuidString

  public init(url: URL) {
    self.url = url
  }

  public func makeURLRequest() -> URLRequest {
    var request = URLRequest(url: url)

    request.httpMethod = "POST"
    request.setValue(
      "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    let body = makeBody(withBoundary: boundary)

    request.httpBody = body
    return request
  }

  private func makeBody(withBoundary boundary: String) -> Data {
    let boundaryDelimiter = "--\(boundary)\r\n".data(using: .utf8)!
    let boundaryEndLimiter = "--\(boundary)--".data(using: .utf8)!
    var body =
      fields
      .map { $0.value.makeField(forKey: $0.key) }
      .map({
        boundaryDelimiter + $0
      })
      .reduce(into: Data()) { partialResult, newData in
        partialResult.append(newData)
      }
    body.append(boundaryEndLimiter)
    return body
  }

  public subscript(form key: String) -> String? {
    get {
      guard case let .form(value) = fields[key] else { return nil }
      return value
    }
    set {
      guard let newValue else {
        fields.removeValue(forKey: key)
        return
      }
      fields[key] = .form(newValue)
    }
  }

  public subscript(file key: String) -> Data? {
    get {
      guard case let .file(value) = fields[key] else { return nil }
      return value
    }
    set {
      guard let newValue else {
        fields.removeValue(forKey: key)
        return
      }
      fields[key] = .file(newValue)
    }
  }
}

extension MultipartURLRequestBuilder.RequestData {
  func makeField(forKey key: String) -> Data {
    switch self {
    case let .form(form):
      return """
        Content-Disposition: form-data; name="\(key)"\r
        \r
        \(form)\r

        """.data(using: .utf8)!
    case let .file(file):
      var base = """
        Content-Disposition: form-data; name="file"; filename="\(key)"\r
        Content-Type: application/octet-stream\r
        \r

        """.data(using: .utf8)!
      base.append(file)
      base.append("\r\n".data(using: .utf8)!)
      return base
    }
  }
}
