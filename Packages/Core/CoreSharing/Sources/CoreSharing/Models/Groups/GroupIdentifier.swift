import CoreTypes
import Foundation

enum GroupIdentifier: Sendable {
  case itemGroup(Identifier)
  case userGroup(Identifier)
  case collection(Identifier)

  var id: Identifier {
    switch self {
    case .itemGroup(let id), .userGroup(let id), .collection(let id):
      return id
    }
  }

  var itemGroupId: Identifier? {
    switch self {
    case .itemGroup(let id):
      return id
    case .userGroup, .collection:
      return nil
    }
  }

  var userGroupId: Identifier? {
    switch self {
    case .itemGroup, .collection:
      return nil
    case .userGroup(let id):
      return id
    }
  }

  var collectionId: Identifier? {
    switch self {
    case .itemGroup, .userGroup:
      return nil
    case .collection(let id):
      return id
    }
  }
}

protocol GroupIdentifiable {
  var groupIdentifier: GroupIdentifier { get }
}

extension UserGroup: GroupIdentifiable {
  var groupIdentifier: GroupIdentifier {
    return .userGroup(id)
  }
}

extension ItemGroup: GroupIdentifiable {
  var groupIdentifier: GroupIdentifier {
    return .itemGroup(id)
  }
}

extension SharingCollection: GroupIdentifiable {
  var groupIdentifier: GroupIdentifier {
    return .collection(id)
  }
}
