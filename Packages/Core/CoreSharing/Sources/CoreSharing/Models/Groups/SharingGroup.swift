import CoreTypes
import Foundation
import LogFoundation

public protocol SharingGroup: Sendable, Loggable {
  associatedtype Info: Identifiable where Info.ID == Identifier

  var info: Info { get }
  var users: [User<Self>] { get }
}

extension SharingGroup {
  public func user(with userId: UserId) -> User<Self>? {
    return users.first { $0.id == userId }
  }
}
