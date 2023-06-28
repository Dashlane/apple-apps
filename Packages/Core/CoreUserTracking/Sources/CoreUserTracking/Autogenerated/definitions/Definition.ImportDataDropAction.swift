import Foundation

extension Definition {

public enum `ImportDataDropAction`: String, Encodable {
case `cancelProcess` = "cancel_process"
case `shutDownBrowserTab` = "shut_down_browser_tab"
case `switchedWebappSection` = "switched_webapp_section"
}
}