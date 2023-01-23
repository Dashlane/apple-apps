import Foundation

extension Definition {

public enum `Button`: String, Encodable {
case `back`
case `cancel`
case `discard`
case `done`
case `next`
case `ok`
case `searchBar` = "search_bar"
case `seeAll` = "see_all"
case `skip`
case `submit`
}
}