import Foundation

public struct CompleteLoginRequestInfo: Encodable {
  let login: String
  let deviceAccessKey: String
  let authTicket: String
}
