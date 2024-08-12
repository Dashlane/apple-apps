import Foundation

public class CreditCardDateFormatter: DateFormatter {
  override public init() {
    super.init()
    dateFormat = "MM / yyyy"
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
