import Foundation

public struct UseractivityCreateActivity: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case autologins = "autologins"
    case averagePasswordStrength = "averagePasswordStrength"
    case checkedPasswords = "checkedPasswords"
    case compromisedPasswords = "compromisedPasswords"
    case nbrPasswords = "nbrPasswords"
    case oldPasswords = "oldPasswords"
    case passwordstrength019Count = "passwordStrength0_19Count"
    case passwordstrength2039Count = "passwordStrength20_39Count"
    case passwordstrength4059Count = "passwordStrength40_59Count"
    case passwordstrength6079Count = "passwordStrength60_79Count"
    case passwordstrength80100Count = "passwordStrength80_100Count"
    case reused = "reused"
    case reusedDistinct = "reusedDistinct"
    case safePasswords = "safePasswords"
    case securityIndex = "securityIndex"
    case weakPasswords = "weakPasswords"
  }

  public let autologins: Int?
  public let averagePasswordStrength: Int?
  public let checkedPasswords: Int?
  public let compromisedPasswords: Int?
  public let nbrPasswords: Int?
  public let oldPasswords: Int?
  public let passwordstrength019Count: Int?
  public let passwordstrength2039Count: Int?
  public let passwordstrength4059Count: Int?
  public let passwordstrength6079Count: Int?
  public let passwordstrength80100Count: Int?
  public let reused: Int?
  public let reusedDistinct: Int?
  public let safePasswords: Int?
  public let securityIndex: Int?
  public let weakPasswords: Int?

  public init(
    autologins: Int? = nil, averagePasswordStrength: Int? = nil, checkedPasswords: Int? = nil,
    compromisedPasswords: Int? = nil, nbrPasswords: Int? = nil, oldPasswords: Int? = nil,
    passwordstrength019Count: Int? = nil, passwordstrength2039Count: Int? = nil,
    passwordstrength4059Count: Int? = nil, passwordstrength6079Count: Int? = nil,
    passwordstrength80100Count: Int? = nil, reused: Int? = nil, reusedDistinct: Int? = nil,
    safePasswords: Int? = nil, securityIndex: Int? = nil, weakPasswords: Int? = nil
  ) {
    self.autologins = autologins
    self.averagePasswordStrength = averagePasswordStrength
    self.checkedPasswords = checkedPasswords
    self.compromisedPasswords = compromisedPasswords
    self.nbrPasswords = nbrPasswords
    self.oldPasswords = oldPasswords
    self.passwordstrength019Count = passwordstrength019Count
    self.passwordstrength2039Count = passwordstrength2039Count
    self.passwordstrength4059Count = passwordstrength4059Count
    self.passwordstrength6079Count = passwordstrength6079Count
    self.passwordstrength80100Count = passwordstrength80100Count
    self.reused = reused
    self.reusedDistinct = reusedDistinct
    self.safePasswords = safePasswords
    self.securityIndex = securityIndex
    self.weakPasswords = weakPasswords
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(autologins, forKey: .autologins)
    try container.encodeIfPresent(averagePasswordStrength, forKey: .averagePasswordStrength)
    try container.encodeIfPresent(checkedPasswords, forKey: .checkedPasswords)
    try container.encodeIfPresent(compromisedPasswords, forKey: .compromisedPasswords)
    try container.encodeIfPresent(nbrPasswords, forKey: .nbrPasswords)
    try container.encodeIfPresent(oldPasswords, forKey: .oldPasswords)
    try container.encodeIfPresent(passwordstrength019Count, forKey: .passwordstrength019Count)
    try container.encodeIfPresent(passwordstrength2039Count, forKey: .passwordstrength2039Count)
    try container.encodeIfPresent(passwordstrength4059Count, forKey: .passwordstrength4059Count)
    try container.encodeIfPresent(passwordstrength6079Count, forKey: .passwordstrength6079Count)
    try container.encodeIfPresent(passwordstrength80100Count, forKey: .passwordstrength80100Count)
    try container.encodeIfPresent(reused, forKey: .reused)
    try container.encodeIfPresent(reusedDistinct, forKey: .reusedDistinct)
    try container.encodeIfPresent(safePasswords, forKey: .safePasswords)
    try container.encodeIfPresent(securityIndex, forKey: .securityIndex)
    try container.encodeIfPresent(weakPasswords, forKey: .weakPasswords)
  }
}
