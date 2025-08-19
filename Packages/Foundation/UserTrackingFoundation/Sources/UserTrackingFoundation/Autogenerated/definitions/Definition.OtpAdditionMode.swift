import Foundation

extension Definition {

  public enum `OtpAdditionMode`: String, Encodable, Sendable {
    case `qrCode` = "qr_code"
    case `textCode` = "text_code"
  }
}
