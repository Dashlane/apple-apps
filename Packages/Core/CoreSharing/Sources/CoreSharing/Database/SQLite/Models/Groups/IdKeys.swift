import DashTypes
import Foundation
import GRDB

enum IdKeys: String {
  case id
  case parentGroupId
  case itemGroupId
  case collectionId
}

extension Column {
  static var id: Column {
    return Column(IdKeys.id.rawValue)
  }

  static var parentGroupId: Column {
    return Column(IdKeys.parentGroupId.rawValue)
  }

  static var itemGroupId: Column {
    return Column(IdKeys.itemGroupId.rawValue)
  }

  static var collectionId: Column {
    return Column(IdKeys.collectionId.rawValue)
  }
}

extension SharingGroupMember where Self: FetchableRecord & PersistableRecord {
  static func filter(id: String, parentGroupId: Identifier) -> QueryInterfaceRequest<Self> {
    filter(key: [
      IdKeys.id.rawValue: id,
      IdKeys.parentGroupId.rawValue: parentGroupId,
    ])
  }
}
