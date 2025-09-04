import Foundation

public enum MasterKey: Equatable, Hashable, Sendable {
  case masterPassword(String)
  case key(Data)

  public var value: Any {
    switch self {
    case .masterPassword(let masterPassword):
      return masterPassword
    case .key(let data):
      return data
    }
  }
}
