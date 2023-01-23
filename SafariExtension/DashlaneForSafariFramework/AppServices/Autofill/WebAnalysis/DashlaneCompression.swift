import Foundation
import Compression


fileprivate func perform(operation: compression_stream_operation,
                         algorithm: compression_algorithm,
                         source: Data,
                         destination: inout Data
                         ) -> Bool
{
    return source.withUnsafeBytes { sourcePtr in
        
        let sourceSize = source.count
        
        let streamBase = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
        defer { streamBase.deallocate() }
        var stream = streamBase.pointee
        
        let status = compression_stream_init(&stream, operation, algorithm)
        guard status != COMPRESSION_STATUS_ERROR else { return false }
        defer { compression_stream_destroy(&stream) }
        
        let bufferSize = Swift.max( Swift.min(sourceSize, 64 * 1024), 64)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        
        stream.dst_ptr  = buffer
        stream.dst_size = bufferSize
        stream.src_ptr  = sourcePtr.baseAddress!.bindMemory(to: UInt8.self, capacity: sourceSize)
        stream.src_size = sourceSize
        
        let flags: Int32 = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
        
        while true {
            switch compression_stream_process(&stream, flags) {
            case COMPRESSION_STATUS_OK:
                guard stream.dst_size == 0 else { return false }
                destination.append(buffer, count: stream.dst_ptr - buffer)
                stream.dst_ptr = buffer
                stream.dst_size = bufferSize
                
            case COMPRESSION_STATUS_END:
                destination.append(buffer, count: stream.dst_ptr - buffer)
                return true
                
            default:
                return false
            }
        }
    }
}


public struct DashlaneCompression {

    public static func inflate(compressed: Data) -> Data? {
                                        guard compressed.count > 6 else { return nil }
        guard compressed[4] == 0x78
            && (compressed[5] == 0x01 || compressed[5] == 0x9c || compressed[5] == 0xda) else { return nil }
        
        let expected: UInt32 = (UInt32(compressed[0])<<24)
            | (UInt32(compressed[1])<<16)
            | (UInt32(compressed[2])<<8)
            | (UInt32(compressed[3])<<0)
        
        var decompressed = Data()
        let success = perform(operation: COMPRESSION_STREAM_DECODE, algorithm: COMPRESSION_ZLIB, source: compressed[6...], destination: &decompressed)
        guard success else {
            return nil
        }
        guard decompressed.count == expected else {
            return nil
        }
        return decompressed
    }
    
    public static func deflate(uncompressed: Data) -> Data? {
        let zipHeader = Data([0x78, 0x9C])
        let expected: UInt32 = UInt32(uncompressed.count)
        
        var result = Data()
        result.append( UInt8((expected >> 24) & 0xff) )
        result.append( UInt8((expected >> 16) & 0xff) )
        result.append( UInt8((expected >> 8) & 0xff) )
        result.append( UInt8((expected >> 0) & 0xff) )
        result.append(zipHeader)
        
        let success = perform(operation: COMPRESSION_STREAM_ENCODE, algorithm: COMPRESSION_ZLIB, source: uncompressed, destination: &result)
        guard success else {
            return nil
        }
        return result
    }

}

