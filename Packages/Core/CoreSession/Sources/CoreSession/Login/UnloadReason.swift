import Foundation

public enum SessionServicesUnloadReason: Sendable {
  case masterPasswordChanged
  case restoreSpiegelDataBase
  case userLogsOut
  case masterPasswordChangedForARK
  case loginEmailChanged
}
