import Foundation
import StoreKit

public protocol ReceiptProvider {
  func receipt() async throws -> Data
  func refresh() async throws
}

extension Bundle: ReceiptProvider {
  private func receiptData() throws -> Data {
    guard let appStoreReceiptURL = appStoreReceiptURL,
      let data = try? Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
    else {
      throw URLError(.fileDoesNotExist)
    }

    return data
  }

  public func receipt() async throws -> Data {
    do {
      return try receiptData()
    } catch let error as URLError where error.code == .fileDoesNotExist {
      try await refresh()
      return try receiptData()
    }
  }

  public func refresh() async throws {
    try await AsyncSKRefreshRequest().perform()
  }
}

class AsyncSKRefreshRequest: SKReceiptRefreshRequest {
  var continuation: CheckedContinuation<Void, Error>?

  override init() {
    super.init()

    self.delegate = self
  }

  func perform() async throws {
    try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
      self.start()
    }
  }
}

extension AsyncSKRefreshRequest: SKRequestDelegate {
  func requestDidFinish(_ request: SKRequest) {
    continuation?.resume()
  }

  func request(_ request: SKRequest, didFailWithError error: Error) {
    continuation?.resume(throwing: error)
  }
}
