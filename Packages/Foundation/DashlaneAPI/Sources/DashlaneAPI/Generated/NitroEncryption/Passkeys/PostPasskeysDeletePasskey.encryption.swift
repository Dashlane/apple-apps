import Foundation

extension UserSecureNitroEncryptionAPIClient.Passkeys {
  public struct DeletePasskey: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/passkeys/DeletePasskey"

    public let api: UserSecureNitroEncryptionAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      passkeyId: String, encryptionKey: PasskeysPasskeyEncryptionKey, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(passkeyId: passkeyId, encryptionKey: encryptionKey)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var deletePasskey: DeletePasskey {
    DeletePasskey(api: api)
  }
}

extension UserSecureNitroEncryptionAPIClient.Passkeys.DeletePasskey {
  public typealias Body = PasskeysPasskeyBody
}

extension UserSecureNitroEncryptionAPIClient.Passkeys.DeletePasskey {
  public typealias Response = Empty?
}
