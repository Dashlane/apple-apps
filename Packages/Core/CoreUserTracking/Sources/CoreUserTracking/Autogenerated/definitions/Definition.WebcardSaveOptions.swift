import Foundation

extension Definition {

  public enum `WebcardSaveOptions`: String, Encodable, Sendable {
    case `replace`
    case `save`
    case `saveAsNew` = "save_as_new"
    case `trustAndAutofill` = "trust_and_autofill"
    case `trustAndPaste` = "trust_and_paste"
  }
}
