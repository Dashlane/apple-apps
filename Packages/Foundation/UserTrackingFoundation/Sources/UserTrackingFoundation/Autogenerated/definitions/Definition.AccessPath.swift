import Foundation

extension Definition {

  public enum `AccessPath`: String, Encodable, Sendable {
    case `mainDashboardButton` = "main_dashboard_button"
    case `navLeftMenuButton` = "nav_left_menu_button"
  }
}
