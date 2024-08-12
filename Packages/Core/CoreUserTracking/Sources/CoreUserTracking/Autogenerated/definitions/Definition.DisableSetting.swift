import Foundation

extension Definition {

  public struct `DisableSetting`: Encodable, Sendable {
    public init(
      `configuration`: Definition.AutofillConfiguration? = nil,
      `durationSetting`: Definition.AutofillDurationSetting? = nil,
      `scope`: Definition.AutofillScope? = nil
    ) {
      self.configuration = configuration
      self.durationSetting = durationSetting
      self.scope = scope
    }
    public let configuration: Definition.AutofillConfiguration?
    public let durationSetting: Definition.AutofillDurationSetting?
    public let scope: Definition.AutofillScope?
  }
}
