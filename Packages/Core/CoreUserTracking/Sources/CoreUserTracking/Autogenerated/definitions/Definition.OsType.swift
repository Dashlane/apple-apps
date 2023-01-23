import Foundation

extension Definition {

public enum `OsType`: String, Encodable {
case `android`
case `blackberry`
case `chromeOs` = "chrome_os"
case `debian`
case `electron`
case `fedora`
case `firefoxOs` = "firefox_os"
case `freebsd`
case `haiku`
case `ipad`
case `iphone`
case `linux`
case `macOs` = "mac_os"
case `mint`
case `netbsd`
case `openbsd`
case `osCarbonUnknown` = "os_carbon_unknown"
case `other`
case `playstation`
case `sailfish`
case `solaris`
case `symbian`
case `tizen`
case `ubuntu`
case `windows`
case `windowsPhone` = "windows_phone"
}
}