import AuthenticationServices
import CorePersonalData
import DashTypes
import Foundation
import VaultKit

public typealias Rank = Int
public typealias SnapshotDictionary<Identity: Hashable> = [Identity: Rank]

public struct SnapshotSummary: Codable, Equatable {

  public struct PasskeyIdentity: Codable, Hashable {
    let vaultId: Identifier
    let relyingPartyIdentifier: String
    let userName: String
    let credentialId: Data
    let userHandle: Data
  }

  public struct CredentialIdentity: Codable, Hashable {
    let vaultId: Identifier
    let serviceIdentifier: String
    let user: String
  }

  var credentials: SnapshotDictionary<CredentialIdentity>
  var passkeys: SnapshotDictionary<PasskeyIdentity>

  var isEmpty: Bool {
    return passkeys.isEmpty && credentials.isEmpty
  }

  public init(
    credentials: SnapshotDictionary<SnapshotSummary.CredentialIdentity> = [:],
    passkeys: SnapshotDictionary<SnapshotSummary.PasskeyIdentity> = [:]
  ) {
    if #available(iOS 17, *) {
      self.passkeys = passkeys
    } else {
      self.passkeys = [:]
    }
    self.credentials = credentials
  }
}

extension SnapshotDictionary<SnapshotSummary.CredentialIdentity> {
  func makeIdentities() -> [ASPasswordCredentialIdentity] {
    self.map { (identity, rank) in
      let identity = ASPasswordCredentialIdentity(
        serviceIdentifier: ASCredentialServiceIdentifier(
          identifier: identity.serviceIdentifier, type: .domain),
        user: identity.user,
        recordIdentifier: identity.vaultId.rawValue)
      identity.rank = rank
      return identity
    }
  }
}

extension SnapshotDictionary<SnapshotSummary.PasskeyIdentity> {
  @available(iOS 17.0, macOS 14.0, *)
  func makeIdentities() -> [ASPasskeyCredentialIdentity] {
    self.map { (identity, rank) in
      let identity = ASPasskeyCredentialIdentity(
        relyingPartyIdentifier: identity.relyingPartyIdentifier,
        userName: identity.userName,
        credentialID: identity.credentialId,
        userHandle: identity.userHandle,
        recordIdentifier: identity.vaultId.rawValue)
      identity.rank = rank
      return identity
    }
  }
}

extension SnapshotSummary {
  init(credentials: some Collection<Credential>, passkeys: some Collection<Passkey>) {
    self.init(credentials: credentials.makeSnapshots(), passkeys: passkeys.makeSnapshots())
  }
}

extension Collection<Credential> {
  public func makeSnapshots() -> SnapshotDictionary<SnapshotSummary.CredentialIdentity> {
    var snapshots = SnapshotDictionary<SnapshotSummary.CredentialIdentity>()

    for credential in self {
      let rank = credential.autofillRank
      for identity in credential.makeCredentialIdentities() {
        snapshots[identity] = rank
      }
    }

    return snapshots
  }
}

extension Collection<Passkey> {
  public func makeSnapshots() -> SnapshotDictionary<SnapshotSummary.PasskeyIdentity> {
    var snapshots = SnapshotDictionary<SnapshotSummary.PasskeyIdentity>()

    for passkey in self {
      guard let decodedCredentialId = Data(base64URLEncoded: passkey.credentialId),
        let decodedUserHandle = Data(base64URLEncoded: passkey.userHandle)
      else {
        continue
      }

      let rank = passkey.autofillRank
      let identity = SnapshotSummary.PasskeyIdentity(
        vaultId: passkey.id,
        relyingPartyIdentifier: passkey.relyingPartyId.rawValue,
        userName: passkey.userDisplayName,
        credentialId: decodedCredentialId,
        userHandle: decodedUserHandle)
      snapshots[identity] = rank
    }

    return snapshots
  }
}

extension VaultItem {
  fileprivate var autofillRank: Int {
    if let lastUse = metadata.lastLocalUseDate {
      return Int(lastUse.timeIntervalSince1970)
    } else if let userModificationDatetime = userModificationDatetime {
      return Int(userModificationDatetime.timeIntervalSince1970)
    } else if let creationDatetime = creationDatetime {
      return Int(creationDatetime.timeIntervalSince1970)
    } else {
      return 0
    }
  }
}
