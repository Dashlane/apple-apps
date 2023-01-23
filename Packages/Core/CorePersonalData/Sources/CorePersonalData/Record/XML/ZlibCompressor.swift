import Foundation
import zlib

struct ZlibCompressor {
    public enum Error: Swift.Error {
        case zlibError(code: Int, step: Step)
        case cannotCompressData
        case emptyInputData
        case invalidInputData(_ reason: String)
        case decompressedDataSizeMismatch(expected: Int, actual: Int)
    }
    
    public enum Step {
        case deflateInit
        case deflate
        case inflateInit
        case inflate
    }
    
    private static let bufferSize = 16 * 1024
    private static let defaultCompressionLevel = 7
    
    static func deflate(string: String, compressionLevel: Int = defaultCompressionLevel) throws -> Data {
        guard let dataToCompress = string.data(using: .utf8) else {
            throw Error.cannotCompressData
        }
        
        return try self.deflate(data: dataToCompress)
    }
    
    static func deflate(data inputData: Data, compressionLevel: Int = defaultCompressionLevel) throws -> Data {
        guard inputData.count > 0 else {
            throw Error.emptyInputData
        }
        
        var deflatedData = Data()
        
        try inputData.withUnsafeBytes { (inputPointer: UnsafeRawBufferPointer) in
            guard let address = inputPointer.bindMemory(to: Bytef.self).baseAddress else {
                throw Error.emptyInputData
            }
            
            var stream = z_stream()
            stream.zalloc = nil
            stream.zfree = nil
            stream.opaque = nil
            stream.next_in = UnsafeMutablePointer<Bytef>(mutating: address)
            stream.avail_in = UInt32(inputData.count)
            stream.avail_out = UInt32(self.bufferSize)
            
                        let initResult = deflateInit_(&stream, Int32(compressionLevel), zlibVersion(), Int32(MemoryLayout<z_stream>.size))
            guard initResult == Z_OK else {
                throw Error.zlibError(code: Int(initResult), step: .deflateInit)
            }
            defer {
                deflateEnd(&stream)
            }
            
                        var deflateResult: Int32
            let deflateBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: self.bufferSize)
            defer {
                deflateBuffer.deallocate()
            }
            
            repeat {
                deflateBuffer.initialize(repeating: 0, count: self.bufferSize)
                
                stream.next_out = deflateBuffer
                stream.avail_out = UInt32(self.bufferSize)
                
                deflateResult = zlib.deflate(&stream, Z_FINISH)
                
                deflatedData.append(deflateBuffer, count: self.bufferSize - Int(stream.avail_out))
                
            } while (stream.avail_out == 0)
            
            guard deflateResult == Z_STREAM_END else {
                throw Error.zlibError(code: Int(deflateResult), step: .deflate)
            }
        }
        
        return deflatedData
    }
    
    static func inflateToString(_ compressedData: Data) throws -> String? {
        return String(data: try self.inflate(compressedData), encoding: .utf8)
    }
    
    static func inflate(_ compressedData: Data) throws -> Data {
        guard compressedData.count > 0 else {
            throw Error.emptyInputData
        }
     
        var inflatedData = Data(capacity: compressedData.count)
        
        try compressedData.withUnsafeBytes { (inputPointer: UnsafeRawBufferPointer) in
            guard let address = inputPointer.bindMemory(to: Bytef.self).baseAddress else {
                throw Error.emptyInputData
            }
            
            var stream = z_stream()
            stream.zalloc = nil
            stream.zfree = nil
            stream.opaque = nil
            stream.next_in = UnsafeMutablePointer<Bytef>(mutating: address)
            stream.avail_in = UInt32(compressedData.count)
            stream.avail_out = UInt32(self.bufferSize)

                        let initResult = inflateInit_(&stream, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
            guard initResult == Z_OK else {
                throw Error.zlibError(code: Int(initResult), step: .inflateInit)
            }
            defer {
                inflateEnd(&stream)
            }
  
                        var inflateResult: Int32
            let inflateBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: self.bufferSize)
            defer {
                inflateBuffer.deallocate()
            }
            repeat {
                inflateBuffer.initialize(repeating: 0, count: self.bufferSize)

                stream.next_out = inflateBuffer
                stream.avail_out = UInt32(self.bufferSize)
                    
                inflateResult = zlib.inflate(&stream, Z_NO_FLUSH)
                
                inflatedData.append(inflateBuffer, count: self.bufferSize - Int(stream.avail_out))

            } while inflateResult == Z_OK
            
            guard inflateResult == Z_STREAM_END else {
                throw Error.zlibError(code: Int(inflateResult), step: .inflate)
            }
        }
        
        return inflatedData
    }
}

extension String {
            public func toQtCompressedData() throws -> Data {
        guard let data = self.data(using: .utf8) else {
            throw ZlibCompressor.Error.cannotCompressData
        }
        return try data.toQtCompressedData()
    }
}

public extension Data {
            func toQtCompressedData() throws -> Data {
        let bigEndianUncompressedDataSize = UInt32(self.count).bigEndian
        
        var compressedData = Swift.withUnsafeBytes(of: bigEndianUncompressedDataSize) { Data($0) }
        compressedData.append(try ZlibCompressor.deflate(data: self))
        return compressedData
    }
    
            func decompressQtCompressedData() throws -> Data {
        let zlibHeaderSize = MemoryLayout<UInt32>.size
        guard self.count > zlibHeaderSize else {
            throw ZlibCompressor.Error.invalidInputData("Data is too small to be a zlib deflated data")
        }
        
                                
                let deflatedData = self.advanced(by: zlibHeaderSize)
        let inflatedData = try ZlibCompressor.inflate(deflatedData)

        return inflatedData
    }
    
            func decompressQtCompressedDataToString() throws -> String? {
        let decompressedData = try self.decompressQtCompressedData()
        return String(data: decompressedData, encoding: .utf8)
    }
    
                                }
