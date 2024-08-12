import DashTypes
import Foundation

public struct IPCMessageSender<Message: Encodable> {
  let coder: IPCMessageCoderProtocol
  let destination: URL
  let logger: Logger
  let coordinator = NSFileCoordinator()

  public init(coder: IPCMessageCoderProtocol, destination: URL, logger: Logger) {
    self.coder = coder
    self.destination = destination
    self.logger = logger
  }

  public func send(message: Message) {
    guard let encoded = try? coder.encode(message) else {
      return
    }

    coordinator.coordinateWrite(
      of: encoded,
      at: destination
    ) { result in
      switch result {
      case .success:
        logger.debug("Success write at \(destination)")
      case let .failure(error):
        logger.error("Could not write at \(destination) - \(error.localizedDescription)")
      }
    }
  }
}
