import DashTypes
import Foundation
import SwiftTreats

enum FileDownloadResponse: Equatable {
  case noFile
  case notModified
  case data(Data, etag: String?)
}

protocol FileDownloaderProtocol: Sendable {
  func download(at url: URL, etag: String?) async throws -> FileDownloadResponse
}

struct FileDownloader: FileDownloaderProtocol {
  let session: URLSession

  init(session: URLSession = URLSession.shared) {
    self.session = session
  }

  func download(at url: URL, etag: String?) async throws -> FileDownloadResponse {
    var request = URLRequest(url: url, timeoutInterval: 10)
    if let etag = etag {
      request.setValue(etag, forHTTPHeaderField: "If-None-Match")
    }

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      fatalError("should be an http request")
    }

    switch httpResponse.statusCode {
    case 403:
      return .noFile

    case 304:
      return .notModified

    case 200:
      return .data(data, etag: httpResponse.allHeaderFields["Etag"] as? String)

    default:
      throw URLError(.unknown)
    }
  }
}
