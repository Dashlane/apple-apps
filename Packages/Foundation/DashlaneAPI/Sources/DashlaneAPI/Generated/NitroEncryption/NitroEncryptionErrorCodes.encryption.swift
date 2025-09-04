import Foundation

public enum NitroEncryptionErrorCodes {
}

extension NitroEncryptionErrorCodes {
  public enum InvalidRequest: String, Sendable, Hashable, Codable, CaseIterable {
    case invalidAuthentication = "invalid_authentication"

    case invalidEndpoint = "invalid_endpoint"

    case outOfBoundsTimestamp = "out_of_bounds_timestamp"

    case requestMalformed = "request_malformed"

    case unknownUserdeviceKey = "unknown_userdevice_key"

  }
}

extension NitroEncryptionError {
  public func hasInvalidRequestCode(_ errorCode: NitroEncryptionErrorCodes.InvalidRequest) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension NitroEncryptionErrorCodes {
  public enum Logs: String, Sendable, Hashable, Codable, CaseIterable {
    case clientIdentifierNotFound = "client_identifier_not_found"

    case clientSessionNotParsed = "client_session_not_parsed"

    case clientStateinNotFound = "client_statein_not_found"

    case idIsNotUnique = "id_is_not_unique"

    case secureContentNotParsed = "secure_content_not_parsed"

    case secureTunnelMustBeReopened = "secure_tunnel_must_be_reopened"

    case tunnelUUIDNotFound = "tunnel_uuid_not_found"

  }
}

extension NitroEncryptionError {
  public func hasLogsCode(_ errorCode: NitroEncryptionErrorCodes.Logs) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension NitroEncryptionErrorCodes {
  public enum Passkeys: String, Sendable, Hashable, Codable, CaseIterable {
    case algorithmNotSupportedError = "algorithm_not_supported_error"

    case clientIdentifierNotFound = "client_identifier_not_found"

    case clientSessionNotParsed = "client_session_not_parsed"

    case clientStateinNotFound = "client_statein_not_found"

    case invalidStateError = "invalid_state_error"

    case passkeyDecryptionError = "passkey_decryption_error"

    case passkeyNotFound = "passkey_not_found"

    case secureContentNotParsed = "secure_content_not_parsed"

    case secureTunnelMustBeReopened = "secure_tunnel_must_be_reopened"

    case securityError = "security_error"

    case tunnelUUIDNotFound = "tunnel_uuid_not_found"

  }
}

extension NitroEncryptionError {
  public func hasPasskeysCode(_ errorCode: NitroEncryptionErrorCodes.Passkeys) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension NitroEncryptionErrorCodes {
  public enum Tunnel: String, Sendable, Hashable, Codable, CaseIterable {
    case clientIdentifierNotFound = "client_identifier_not_found"

    case clientSessionKeysNotFound = "client_session_keys_not_found"

    case clientSessionNotParsed = "client_session_not_parsed"

    case clientStateinNotFound = "client_statein_not_found"

    case secureContentNotParsed = "secure_content_not_parsed"

    case secureTunnelMustBeReopened = "secure_tunnel_must_be_reopened"

    case tunnelUUIDNotFound = "tunnel_uuid_not_found"

  }
}

extension NitroEncryptionError {
  public func hasTunnelCode(_ errorCode: NitroEncryptionErrorCodes.Tunnel) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension NitroEncryptionErrorCodes {
  public enum Uvvs: String, Sendable, Hashable, Codable, CaseIterable {
    case clientIdentifierNotFound = "client_identifier_not_found"

    case clientSessionNotParsed = "client_session_not_parsed"

    case clientStateinNotFound = "client_statein_not_found"

    case secureContentNotParsed = "secure_content_not_parsed"

    case secureTunnelMustBeReopened = "secure_tunnel_must_be_reopened"

    case tunnelUUIDNotFound = "tunnel_uuid_not_found"

    case uvvsNotEnabled = "uvvs_not_enabled"

  }
}

extension NitroEncryptionError {
  public func hasUvvsCode(_ errorCode: NitroEncryptionErrorCodes.Uvvs) -> Bool {
    self.has(errorCode.rawValue)
  }
}
