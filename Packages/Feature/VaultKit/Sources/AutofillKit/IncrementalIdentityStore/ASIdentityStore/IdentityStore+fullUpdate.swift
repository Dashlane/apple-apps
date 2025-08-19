import AuthenticationServices
import Foundation

extension IdentityStore {
  func fullUpdate(with summary: SnapshotSummary) async throws {
    let identities: [any ASCredentialIdentity] =
      summary.credentials.makeIdentities() + summary.passkeys.makeIdentities()
    try await replaceCredentialIdentities(identities)
  }
}
