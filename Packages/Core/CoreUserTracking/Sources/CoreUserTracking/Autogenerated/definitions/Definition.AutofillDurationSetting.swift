import Foundation

extension Definition {

public enum `AutofillDurationSetting`: String, Encodable {
case `onceForThisVisit` = "once_for_this_visit"
case `untilTurnedBackOff` = "until_turned_back_off"
case `untilTurnedBackOn` = "until_turned_back_on"
}
}