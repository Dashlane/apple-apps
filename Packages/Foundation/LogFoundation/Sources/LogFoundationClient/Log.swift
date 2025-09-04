import Foundation
import LogFoundation

@Loggable
struct Session {
  let login: String = "_"
  let password: String = "_"
}

@Loggable
struct Session2 {
  @LogPublicPrivacy
  let login: String = "_"
  let password: String = "_"
}

@Loggable
struct Session3 {
  @LogPublicPrivacy
  let login: String = "_"
  let password: Password = .init(id: 123, value: "_")
}

@Loggable
struct Session4 {
  @LogPublicPrivacy
  let login: String = "_"
  let masterKey: MasterKey3 = .password(.init(id: 123, value: "_"))
}

@Loggable
struct Password {
  let id: Int
  let value: String
}

@Loggable
enum MasterKey {
  case password
  case sso
}

@Loggable
enum MasterKey2 {
  @LogPublicPrivacy
  case password(String)
  case sso
}

@Loggable
enum MasterKey3 {
  case password(Password)
  case sso
}
