import Combine
import CoreTypes
import Foundation
import LogFoundation
import SwiftTreats

public class IPCMessageListener<Message: Decodable> {
  private let messagePublisher = CurrentValueSubject<Message?, Never>(nil)
  private let logger: Logger
  private let urlToObserve: URL
  private let coder: IPCMessageCoderProtocol
  private let shouldDeleteAfterReading: Bool
  private let coordinator: NSFileCoordinator
  private var task: Task<Void, Error>?

  public init(
    urlToObserve: URL, coder: IPCMessageCoderProtocol, logger: Logger,
    shouldDeleteAfterReading: Bool = true
  ) {
    self.urlToObserve = urlToObserve
    self.coder = coder
    self.logger = logger
    self.shouldDeleteAfterReading = shouldDeleteAfterReading
    self.coordinator = NSFileCoordinator()
    coordinator.coordinate(
      readingItemAt: urlToObserve, options: [], writingItemAt: urlToObserve, options: .forReplacing,
      error: nil
    ) { readURL, writeURL in
      if !FileManager.default.fileExists(atPath: readURL.path) {
        let directory = readURL.deletingLastPathComponent()
        try? FileManager.default.createDirectoryIfNotExisting(at: directory)
        try? Data().write(to: writeURL)
      }
    }

    task = Task {
      for try await _ in urlToObserve.events(.write) {
        coordinatedRead()
      }
    }
  }

  deinit {
    task?.cancel()
  }

  public var publisher: AnyPublisher<Message, Never> {
    self.messagePublisher.compactMap { $0 }.eraseToAnyPublisher()
  }

  public func read() {
    self.coordinatedRead()
  }

  private func coordinatedRead() {
    coordinator.coordinate(
      readingItemAt: urlToObserve, options: [], writingItemAt: urlToObserve, options: .forReplacing,
      error: nil
    ) { readURL, writeURL in
      logger.info("Accessing \(readURL.path)")
      logger.info("\(readURL.path) contains \((try? Data(contentsOf: readURL).count) ?? 0) bytes")
      do {
        let content = try Data(contentsOf: readURL)
        guard !content.isEmpty else { return }
        if shouldDeleteAfterReading {
          try? Data().write(to: writeURL)
        }
        let decoded: Message = try coder.decode(content)
        self.messagePublisher.send(decoded)
      } catch {
        logger.fatal("Read IPC message failed", error: error)
        try? Data().write(to: writeURL)
      }
    }
  }
}

extension IPCMessageListener {
  public var messages: AsyncPublisher<AnyPublisher<Message, Never>> {
    return publisher.values
  }
}
