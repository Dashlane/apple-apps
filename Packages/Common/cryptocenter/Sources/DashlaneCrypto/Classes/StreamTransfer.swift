import Foundation

public final class StreamTransferError: GenericError {}

public typealias StreamTransferCompletionHandler = (Result<StreamTransfer, Error>) -> Void

public class StreamTransfer: NSObject {

    let inputStream: InputStream?
    let outputStream: OutputStream?
    let completionHandler: StreamTransferCompletionHandler?
    let chunkSize: Int
    let queue: DispatchQueue

    public init(source: URL,
         destination: URL,
         chunkSize: Int = 2048,
         queue: DispatchQueue = DispatchQueue.global(),
         completionHandler: StreamTransferCompletionHandler?) throws {
        guard let inputStream = InputStream(url: source) else {
            throw StreamTransferError("Could not create input stream")
        }
        guard let outputStream = OutputStream(url: destination, append: true) else {
            throw StreamTransferError("Could not create output stream")
        }
        self.completionHandler = completionHandler
        self.chunkSize = chunkSize
        self.queue = queue
        self.inputStream = inputStream
        self.outputStream = outputStream
        super.init()
        outputStream.delegate = self
        inputStream.delegate = self
    }

                        public func process(bytes: [UInt8]) throws -> [UInt8]? {
                return bytes
    }

                public func startOfFile() throws {
            }

                    public func write(_ bytes: [UInt8]) throws {
        guard !bytes.isEmpty else {
            return
        }
        guard let stream = outputStream else {
            throw StreamTransferError("Steam does not exist")
        }
        let status = stream.write(bytes, maxLength: bytes.count)
        guard status == bytes.count else {
            throw StreamTransferError("Could not write data, status \(status)")
        }
    }

                public func endOfFile() throws {
            }

        public func start() throws {
        queue.async { [weak self] in
            if let strongSelf = self {
                let loop = RunLoop.current
                strongSelf.outputStream?.schedule(in: loop, forMode: RunLoop.Mode.common)
                strongSelf.outputStream?.open()
                strongSelf.inputStream?.schedule(in: loop, forMode: RunLoop.Mode.common)
                loop.run()
            }
        }
    }
}

extension StreamTransfer {

        public func closeStreams() {
        inputStream?.delegate = nil
        outputStream?.delegate = nil
        inputStream?.close()
        outputStream?.close()
    }

    private func stream(opened stream: Stream) throws {
        if stream == outputStream {
                                                self.inputStream?.open()
                                                try startOfFile()
        }
    }

    private func stream(bytesReceivedOn stream: Stream) throws {
        guard let inputStream = stream as? InputStream else {
            throw StreamTransferError("Unexpected stream received bytes")
        }
                                                let bytes = read(input: inputStream)
        if let processed = try process(bytes: bytes) {
            try write(processed)
        }
    }

    private func stream(endFor stream: Stream) throws {
        guard stream == inputStream else {
            throw StreamTransferError("Unexpected stream ended")
        }
        try endOfFile()
        closeStreams()
    }
}

extension StreamTransfer: StreamDelegate {

                        public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        do {
            switch eventCode {
            case Stream.Event.openCompleted:
                try stream(opened: aStream)
            case Stream.Event.hasBytesAvailable:
                try stream(bytesReceivedOn: aStream)
                break
            case Stream.Event.errorOccurred:
                closeStreams()
                completionHandler?(.failure(StreamTransferError("Stream error occurred")))
                break
            case Stream.Event.endEncountered:
                try stream(endFor: aStream)
                completionHandler?(.success(self))
                break
            default:
                break
            }
        } catch {
            closeStreams()
            completionHandler?(.failure(error))
        }
    }
}

extension StreamTransfer {

                func read(input: InputStream) -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: chunkSize)
        let readLength = input.read(&buffer, maxLength: chunkSize)
        return Array(buffer[0..<readLength])
    }
}
