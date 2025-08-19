import Foundation

extension Definition {

  public enum `Origin`: String, Encodable, Sendable {
    case `collectionDetailView` = "collection_detail_view"
    case `collectionLeftHandSideMenuQuickActionsDropdown` =
      "collection_left_hand_side_menu_quick_actions_dropdown"
    case `collectionListView` = "collection_list_view"
    case `collectionListViewQuickActionsDropdown` = "collection_list_view_quick_actions_dropdown"
    case `itemDetailView` = "item_detail_view"
    case `itemListView` = "item_list_view"
    case `itemListViewQuickActionsDropdown` = "item_list_view_quick_actions_dropdown"
    case `searchQuickActionsDropdown` = "search_quick_actions_dropdown"
  }
}
