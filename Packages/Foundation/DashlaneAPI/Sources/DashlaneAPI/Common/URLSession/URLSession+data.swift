import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if os(Linux)
  extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
      return try await withCheckedThrowingContinuation { continuation in
        let task = self.dataTask(with: request) { data, response, error in
          guard let data = data, let response = response else {
            let error = error ?? URLError(.badServerResponse)
            return continuation.resume(throwing: error)
          }
          continuation.resume(returning: (data, response))
        }
        task.resume()
      }
    }
  }
#endif
