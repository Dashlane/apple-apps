import Foundation

extension Definition {

public enum `WebcardSaveOptions`: String, Encodable {
case `replace`
case `save`
case `saveAsNew` = "save_as_new"
}
}