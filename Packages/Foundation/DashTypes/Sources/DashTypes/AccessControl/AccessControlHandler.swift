import Foundation

public typealias AccessControlCompletion = @MainActor (Result<Void, AccessControlError>) -> Void

public protocol AccessControlHandler: Sendable {
  func requestAccess(for reason: AccessControlReason, completion: @escaping AccessControlCompletion)
}

extension AccessControlHandler {
  public func requestAccess(for reason: AccessControlReason, completion: @escaping (Bool) -> Void) {
    self.requestAccess(for: reason) { result in
      completion(result.isSuccess)
    }
  }

  public func requestAccess(for reason: AccessControlReason) async throws {
    try await withCheckedThrowingContinuation { continuation in
      requestAccess(for: reason) { result in
        continuation.resume(with: result)
      }
    }
  }
}

#if canImport(SwiftUI)
  import SwiftUI

  extension AccessControlHandler {
    public func controlEnabling(of binding: Binding<Bool>, reason: AccessControlReason) -> Binding<
      Bool
    > {
      Binding<Bool>.init {
        binding.wrappedValue
      } set: { value in
        if value {
          requestAccess(for: reason) { sucsess in
            binding.wrappedValue = sucsess
          }
        } else {
          binding.wrappedValue = false
        }
      }
    }
  }
#endif

public struct AccessControlHandlerMock: AccessControlHandler {
  let result: Result<Void, AccessControlError>

  public func requestAccess(
    for reason: AccessControlReason, completion: @escaping AccessControlCompletion
  ) {
    Task {
      await completion(result)
    }
  }
}

extension AccessControlHandler where Self == AccessControlHandlerMock {
  public static func mock(result: Result<Void, AccessControlError> = .success(Void()))
    -> AccessControlHandlerMock
  {
    AccessControlHandlerMock(result: result)
  }
}

public struct AccessControlDefaultHandler: AccessControlHandler {
  public func requestAccess(
    for reason: AccessControlReason, completion: @escaping AccessControlCompletion
  ) {
    Task {
      await completion(.success)
    }
  }
}

extension AccessControlHandler where Self == AccessControlDefaultHandler {
  public static var `default`: AccessControlDefaultHandler {
    AccessControlDefaultHandler()
  }
}
