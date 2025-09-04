import CorePersonalData
import CoreTypes
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

  public func requestAccess(
    to items: any Collection<any VaultItem>, completion: @escaping AccessControlCompletion
  ) {
    let requireAccess = items.contains { item in
      guard let secureItem = item as? SecureItem else {
        return false
      }

      return secureItem.secured
    }

    if requireAccess {
      requestAccess(for: .unlockItems(count: items.count), completion: completion)
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

  public func requestAccess(
    to items: any Collection<any VaultItem>, completion: @escaping (Bool) -> Void
  ) {
    self.requestAccess(to: items) { result in
      completion(result.isSuccess)
    }
  }

  public func requestAccess(to items: any Collection<any VaultItem>) async throws {
    try await withCheckedThrowingContinuation { continuation in
      requestAccess(to: items) { result in
        continuation.resume(with: result)
      }
    }
  }
}
