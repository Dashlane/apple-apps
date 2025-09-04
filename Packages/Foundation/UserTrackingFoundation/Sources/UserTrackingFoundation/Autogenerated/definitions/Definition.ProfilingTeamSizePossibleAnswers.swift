import Foundation

extension Definition {

  public enum `ProfilingTeamSizePossibleAnswers`: String, Encodable, Sendable {
    case `fiftyOneToTwoHundred` = "fifty_one_to_two_hundred"
    case `fiveHundredOneToOneThousand` = "five_hundred_one_to_one_thousand"
    case `fiveThousandOnePlus` = "five_thousand_one_plus"
    case `oneThousandOneToFiveThousand` = "one_thousand_one_to_five_thousand"
    case `oneToFifty` = "one_to_fifty"
    case `twoHundredOneToFiveHundred` = "two_hundred_one_to_five_hundred"
  }
}
