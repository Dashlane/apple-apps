import Foundation

extension UserEvent {

  public struct `AutofillPasswordGenerateShowMore`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init() {

    }
    public let name = "autofill_password_generate_show_more"
  }
}
