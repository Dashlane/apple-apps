import CorePersonalData
import DashTypes
import Foundation

extension AccessControlHandler {
  public func requestAccess(to item: VaultItem, completion: @escaping AccessControlCompletion) {
    if let secureItem = item as? SecureItem, secureItem.secured {
      requestAccess(for: .unlockItem, completion: completion)
    } else {
      Task {
        await completion(.success)
      }
    }
  }
}

extension AccessControlHandler {
  public func requestAccess(to item: VaultItem, completion: @escaping (Bool) -> Void) {
    self.requestAccess(to: item) { result in
      completion(result.isSuccess)
    }
  }

  public func requestAccess(to item: VaultItem) async throws {
    try await withCheckedThrowingContinuation { continuation in
      requestAccess(to: item) { result in
        continuation.resume(with: result)
      }
    }
  }
}
