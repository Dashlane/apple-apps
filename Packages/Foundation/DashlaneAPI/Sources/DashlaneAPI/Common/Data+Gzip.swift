#if canImport(zlib)
  import Foundation
  import zlib

  extension Data {
    struct GzipConstants {
      static let chunkSize = 4096
    }

    public func gzipCompressed() -> Data? {
      var zstream = z_stream()

      zstream.zalloc = nil
      zstream.zfree = nil
      zstream.opaque = nil

      var status = deflateInit2_(
        &zstream, 5, Z_DEFLATED, 15 + 16, 8, Z_DEFAULT_STRATEGY, ZLIB_VERSION,
        Int32(MemoryLayout<z_stream>.size))
      guard status == Z_OK else {
        return nil
      }

      return self.withUnsafeBytes { (inputPointer: UnsafeRawBufferPointer) in
        var deflatedData = Data()

        let chunk = GzipConstants.chunkSize
        let out = UnsafeMutablePointer<UInt8>.allocate(capacity: chunk)
        defer { out.deallocate() }

        zstream.next_in = UnsafeMutablePointer<Bytef>(
          mutating: inputPointer.bindMemory(to: Bytef.self).baseAddress!)
        zstream.avail_in = uInt(count)

        repeat {
          zstream.avail_out = uInt(chunk)
          zstream.next_out = out

          status = deflate(&zstream, Z_FINISH)

          guard status != Z_STREAM_ERROR else {
            return nil
          }

          let have = chunk - Int(zstream.avail_out)
          deflatedData.append(out, count: have)

        } while zstream.avail_out == 0

        guard deflateEnd(&zstream) == Z_OK else {
          return nil
        }

        return deflatedData
      }

    }

    public func gzipDecompressed() -> Data? {
      var zstream = z_stream()

      zstream.zalloc = nil
      zstream.zfree = nil
      zstream.opaque = nil

      var status = inflateInit2_(
        &zstream, 15 + 16, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
      guard status == Z_OK else { return nil }

      return self.withUnsafeBytes { (inputPointer: UnsafeRawBufferPointer) in
        var inflatedData = Data()

        zstream.next_in = UnsafeMutablePointer<Bytef>(
          mutating: inputPointer.bindMemory(to: Bytef.self).baseAddress!)
        zstream.avail_in = uInt(count)

        let chunk = GzipConstants.chunkSize
        let out = UnsafeMutablePointer<UInt8>.allocate(capacity: chunk)
        defer { out.deallocate() }

        repeat {
          zstream.avail_out = uInt(chunk)
          zstream.next_out = out

          status = inflate(&zstream, Z_FINISH)

          guard status != Z_STREAM_ERROR else {
            return nil
          }

          let have = chunk - Int(zstream.avail_out)
          inflatedData.append(out, count: have)

        } while zstream.avail_out == 0

        guard inflateEnd(&zstream) == Z_OK else {
          return nil
        }

        return inflatedData
      }
    }
  }
#endif
