import Foundation
import UniformTypeIdentifiers

#if !os(macOS)
import MobileCoreServices
#endif


public struct FileInformation {
    
                    static public func size(ofFile url: URL) throws -> UInt64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let size = attributes[FileAttributeKey.size] as? UInt64 else {
            return 0
        }
        return size
    }
    
                    static public func mimeType(of url: URL) -> String? {
        return UTType(filenameExtension: url.pathExtension)?.preferredMIMEType
    }
}
