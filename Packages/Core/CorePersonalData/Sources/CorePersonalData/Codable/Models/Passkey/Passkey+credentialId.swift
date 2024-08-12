import Foundation

extension Collection<Passkey> {
  public func first(with uuid: Passkey.CredentialId) -> Passkey? {
    first { $0.credentialId == uuid }
  }

  public func byCredentialIds() -> [Passkey.CredentialId: Passkey] {
    var dict = [Passkey.CredentialId: Passkey]()

    for passkey in self {
      dict[passkey.credentialId] = passkey
    }

    return dict
  }
}
