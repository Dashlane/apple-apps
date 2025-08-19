import CoreTypes
import Foundation

public class AppAutofillExtensionCommunicationCenter {
  public enum AppMessage: Codable, Hashable {
    case didLogout
    case didLogin(Login)
    case premiumStatusDidUpdate
  }

  private let fileURL: URL
  private let writingQueue: DispatchQueue
  private let fileManger: FileManager = .default

  public init(
    queue: DispatchQueue = .init(label: "Writing Queue", qos: .utility, attributes: .concurrent),
    baseURL: URL = ApplicationGroup.documentsURL
  ) {
    self.fileURL = baseURL.appendingPathComponent("AppToExtensions.messages", isDirectory: false)
    self.writingQueue = queue
  }

  func clear() {
    try? FileManager.default.removeItem(at: self.fileURL)
  }

  public func consumeMessages(shouldClear: Bool = true) -> Set<AppMessage> {
    defer {
      if shouldClear {
        self.clear()
      }
    }
    do {
      let data = try Data.init(contentsOf: fileURL)
      return try JSONDecoder().decode(Set<AppMessage>.self, from: data)
    } catch {
      return .init()
    }
  }

  public func write(message: AppMessage, completion: (() -> Void)? = nil) {
    writingQueue.async { [weak self] in
      defer {
        completion?()
      }
      guard let self = self else { return }
      let currentMessages = self.consumeMessages(shouldClear: false)
      guard !currentMessages.contains(message) else {
        return
      }
      do {
        self.clear()
        let messagesToWrite = Set(currentMessages + [message])
        let data = try JSONEncoder().encode(messagesToWrite)
        try data.write(to: self.fileURL, options: .atomic)
      } catch {
        print(error)
      }
    }
  }
}
