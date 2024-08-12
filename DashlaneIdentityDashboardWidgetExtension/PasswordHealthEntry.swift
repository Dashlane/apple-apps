import Foundation
import WidgetKit

struct PasswordHealthEntry: TimelineEntry {
  let date: Date
  let score: Int?
  let credentialCount: Int?
  let compromisedCount: Int?
  let reusedCount: Int?
  let weakCount: Int?

  var progress: Float {
    return Float(score ?? 0) * 0.75 / 100
  }

  var gaugeValue: Float {
    return Float(score ?? 0) / 100
  }

  var percentage: Int {
    return Int(gaugeValue * 100)
  }

  private init(
    date: Date, score: Int?, credentialCount: Int?, compromisedCount: Int?, reusedCount: Int?,
    weakCount: Int?
  ) {
    self.date = date
    self.score = score
    self.credentialCount = credentialCount
    self.compromisedCount = compromisedCount
    self.reusedCount = reusedCount
    self.weakCount = weakCount
  }

  public init() {
    self.init(
      date: Date(), score: nil, credentialCount: nil, compromisedCount: nil, reusedCount: nil,
      weakCount: nil)
  }

  public init(
    score: Int, credentialCount: Int, compromisedCount: Int, reusedCount: Int, weakCount: Int
  ) {
    self.init(
      date: Date(),
      score: score,
      credentialCount: credentialCount,
      compromisedCount: compromisedCount,
      reusedCount: reusedCount,
      weakCount: weakCount)
  }

  public init(score: Int) {
    self.init(
      date: Date(), score: score, credentialCount: nil, compromisedCount: nil, reusedCount: nil,
      weakCount: nil)
  }
}
