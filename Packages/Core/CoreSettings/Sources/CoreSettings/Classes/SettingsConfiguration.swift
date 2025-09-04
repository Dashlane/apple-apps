import Foundation

public struct SettingsConfiguration: Sendable {
  public let modelURL: URL
  public let storeURL: URL

  public init(modelURL: URL, storeURL: URL) {
    self.modelURL = modelURL
    self.storeURL = storeURL
  }

}
