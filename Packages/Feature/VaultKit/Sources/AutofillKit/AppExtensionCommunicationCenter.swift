import Foundation

public class AppExtensionCommunicationCenter {
  private let fileURL: URL
  private let writingQueue: DispatchQueue
  private let fileManger: FileManager = .default

  public init(
    channel: Channel,
    queue: DispatchQueue = .init(label: "Writing Queue", qos: .utility, attributes: .concurrent),
    baseURL: URL
  ) {
    self.fileURL = baseURL.appendingPathComponent(channel.fileName, isDirectory: false)
    self.writingQueue = queue
  }

  func clear() {
    try? FileManager.default.removeItem(at: self.fileURL)
  }

  public func consumeMessages(shouldClear: Bool = true) -> Set<Message> {
    defer {
      if shouldClear {
        self.clear()
      }
    }
    do {
      let data = try Data.init(contentsOf: fileURL)
      return try JSONDecoder.init().decode(Set<Message>.self, from: data)
    } catch {
      return .init()
    }
  }

  public func write(message: Message, completion: (() -> Void)? = nil) {
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
        let messagesToWrite = Set<Message>.init(currentMessages + [message])
        let data = try JSONEncoder().encode(messagesToWrite)
        try data.write(to: self.fileURL, options: .atomic)
      } catch {
        print(error)
      }
    }
  }
  public enum Channel {
    case fromApp
    case fromTachyon

    var fileName: String {
      switch self {
      case .fromApp:
        return "AppToExtensions.messages"
      case .fromTachyon:
        return "TachyonToApp.messages"
      }
    }
  }

  public enum Message: String, Codable {
    case userDidLogout
    case premiumStatusDidUpdate
  }

}
