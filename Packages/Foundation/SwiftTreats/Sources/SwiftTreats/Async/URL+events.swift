import Foundation

var sources: DispatchSourceFileSystemObject?

extension URL {
    
    public enum AsyncFileSequenceEvent: Equatable {
                case monitoringReady
                case fileSystemEvent(DispatchSource.FileSystemEvent)
    }
    
               public func events(_ event: DispatchSource.FileSystemEvent) -> AsyncThrowingStream<AsyncFileSequenceEvent, Error> {
        AsyncThrowingStream { continuation in
            let descriptor = open(path, O_EVTONLY)
            if descriptor == -1 {
                continuation.finish(throwing: URLError(.cannotOpenFile))
                return
            }

            let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor,
                                                                   eventMask: event,
                                                                   queue: .global(qos: .utility))
            sources = source
            source.setRegistrationHandler {
                continuation.yield(.monitoringReady)
            }
            
            source.setEventHandler { [weak source] in
                guard let event = source?.data else {
                    return
                }
                
                continuation.yield(.fileSystemEvent(event))
            }
            source.setCancelHandler {
                close(descriptor)
            }
            
            continuation.onTermination = { _ in
                guard !source.isCancelled else {
                    return
                }
                source.cancel()
            }
            
            source.resume()
        }
    }
}
