import Foundation

public enum NitroEncryptionErrorCodes {
}

extension NitroEncryptionErrorCodes {
  public enum InvalidRequest: String, Sendable, Equatable, CaseIterable, Codable {
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
  public enum Logs: String, Sendable, Equatable, CaseIterable, Codable {
    case tunnelUUIDNotFound = "tunnel_uuid_not_found"

  }
}

extension NitroEncryptionError {
  public func hasLogsCode(_ errorCode: NitroEncryptionErrorCodes.Logs) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension NitroEncryptionErrorCodes {
  public enum Tunnel: String, Sendable, Equatable, CaseIterable, Codable {
    case clientSessionKeysNotFound = "client_session_keys_not_found"

    case tunnelUUIDNotFound = "tunnel_uuid_not_found"

  }
}

extension NitroEncryptionError {
  public func hasTunnelCode(_ errorCode: NitroEncryptionErrorCodes.Tunnel) -> Bool {
    self.has(errorCode.rawValue)
  }
}
