import Foundation

extension Definition {

  public struct `Context`: Encodable, Sendable {
    public init(
      `app`: Definition.App, `browser`: Definition.Browser? = nil, `device`: Definition.Device,
      `user`: Definition.User? = nil
    ) {
      self.app = app
      self.browser = browser
      self.device = device
      self.user = user
    }
    public let app: Definition.App
    public let browser: Definition.Browser?
    public let device: Definition.Device
    public let user: Definition.User?
  }
}
