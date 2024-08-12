import AuthenticationServices
import Foundation

extension IdentityStore {
  func fullUpdate(with summary: SnapshotSummary) async throws {
    if #available(iOS 17.0, macOS 14.0, *) {
      let identities: [any ASCredentialIdentity] =
        summary.credentials.makeIdentities() + summary.passkeys.makeIdentities()
      try await replaceCredentialIdentities(identities)
    } else {
      try await replaceCredentialIdentities(with: summary.credentials.makeIdentities())
    }
  }
}
