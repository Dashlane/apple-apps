import Foundation

extension Definition {

  public enum `BrowseComponent`: String, Encodable, Sendable {
    case `dashlaneCom` = "dashlane_com"
    case `extensionPopup` = "extension_popup"
    case `extensionWebcard` = "extension_webcard"
    case `mainApp` = "main_app"
    case `osAutofill` = "os_autofill"
    case `tac`
    case `watchApp` = "watch_app"
    case `webcard`
  }
}
