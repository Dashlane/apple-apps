import Foundation

extension Identity {
  public func isPropertyAvailable<T>(for keypath: KeyPath<Identity, T>) -> Bool {
    switch keypath {
    case \Identity.personalTitle:
      return mode != .japanese

    case \Identity.middleName:
      return mode == .northAmerican

    case \Identity.lastName2:
      return mode == .spanish

    default:
      return true
    }
  }
}
