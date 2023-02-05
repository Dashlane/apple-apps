import Foundation
import Combine
import DashTypes
import SwiftTreats

public class IPCMessageListener<Message: Decodable> {
    private let messagePublisher = CurrentValueSubject<Message?, Never>(nil)
    private let logger: Logger
    private let urlToObserve: URL
    private let coder: IPCMessageCoderProtocol
    private let shouldDeleteAfterReading: Bool
    private let fileObserver: FileChangeObserver
    private let coordinator: NSFileCoordinator
    private var subscription: AnyCancellable?

    public init(urlToObserve: URL, coder: IPCMessageCoderProtocol, logger: Logger, shouldDeleteAfterReading: Bool = true) {
        self.urlToObserve = urlToObserve
        self.coder = coder
        self.logger = logger
        self.shouldDeleteAfterReading = shouldDeleteAfterReading
        let fileObserver = FileChangeObserver(url: urlToObserve)
        self.coordinator = NSFileCoordinator(filePresenter: fileObserver)
        self.fileObserver = fileObserver
        coordinator.coordinate(readingItemAt: urlToObserve, options: [], writingItemAt: urlToObserve, options: .forReplacing, error: nil) { readURL, writeURL in
            if !FileManager.default.fileExists(atPath: readURL.path) {
                let directory = readURL.deletingLastPathComponent()
                try? FileManager.default.createDirectoryIfNotExisting(at: directory)
                try? Data().write(to: writeURL)
            }
            NSFileCoordinator.addFilePresenter(fileObserver)
        }
        
        subscription = fileObserver.changePublisher.sink { [weak self] in
            self?.coordinatedRead()
        }
    }

    deinit {
                NSFileCoordinator.removeFilePresenter(fileObserver)
    }

    public var publisher: AnyPublisher<Message, Never> {
        self.messagePublisher.compactMap{ $0 }.eraseToAnyPublisher()
    }

    public func read() {
        self.coordinatedRead()
    }
    
    private func coordinatedRead() {
        coordinator.coordinate(readingItemAt: urlToObserve, options: [], writingItemAt: urlToObserve, options: .forReplacing, error: nil) { readURL, writeURL in
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
                logger.fatal(error.localizedDescription)
            }
        }
    }
}


private class FileChangeObserver: NSObject, NSFilePresenter {
    let url: URL
    let presentedItemOperationQueue: OperationQueue = OperationQueue()
    let changePublisher = PassthroughSubject<Void, Never>()

    var presentedItemURL: URL? {
        url
    }
    
    init(url: URL) {
        self.url = url
    }
    
    func presentedItemDidChange() {
        changePublisher.send()
    }
}

private extension URL {
    func modificationDate() -> Date? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
}

public extension IPCMessageListener {
    @available(iOS 15.0, macOS 12.0, *)
    var messages: AsyncPublisher<AnyPublisher<Message, Never>> {
        return publisher.values
    }
}
