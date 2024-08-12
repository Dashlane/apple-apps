import Foundation

extension Definition {

  public enum `SharingFlowType`: String, Encodable, Sendable {
    case `collectionSharing` = "collection_sharing"
    case `itemSharing` = "item_sharing"
  }
}
