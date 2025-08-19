import CoreSession
import Foundation

@MainActor
enum AccountMigrationResult {
  case cancel
  case failure(any Error)
  case success(Session)

  init(_ result: Result<Session, any Error>) {
    switch result {
    case .success(let session):
      self = .success(session)
    case .failure(let error):
      self = .failure(error)
    }
  }
}

typealias AccountMigrationCompletion = @MainActor (AccountMigrationResult) -> Void
