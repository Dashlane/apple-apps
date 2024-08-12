import Foundation

public class IDCardDateFormatter: DateFormatter {
  override public init() {
    super.init()
    dateFormat = "dd / MM / yyyy"
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
