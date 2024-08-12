import Foundation

extension Definition {

  public enum `CollectionSelectOrigin`: String, Encodable, Sendable {
    case `collectionList` = "collection_list"
    case `itemList` = "item_list"
    case `leftHandSideMenu` = "left_hand_side_menu"
    case `searchResults` = "search_results"
  }
}
