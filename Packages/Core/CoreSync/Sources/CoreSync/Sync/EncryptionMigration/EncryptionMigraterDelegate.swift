import DashTypes
import Foundation

public protocol EncryptionMigraterDelegate: AnyObject {
  associatedtype Output

  @MainActor
  func didProgress(_ progression: EncryptionMigrater<Self>.Progression)

  @MainActor
  func complete(
    with timestamp: Timestamp,
    completionHandler: @escaping @MainActor (Result<Output, Swift.Error>) async -> Void)

  @MainActor
  func didFinish(with result: Result<Output, EncryptionMigrater<Self>.MigraterError>)
}
