import Foundation

extension Data {
  subscript(safe range: Range<Index>) -> Data {
    get throws {
      guard range.lowerBound >= startIndex && range.upperBound <= endIndex else {
        throw CryptoEngineError.insufficientData
      }
      return self[range]
    }
  }

  subscript(safe range: ClosedRange<Index>) -> Data {
    get throws {
      guard
        range.lowerBound >= startIndex && range.upperBound < endIndex && range.lowerBound < endIndex
      else {
        throw CryptoEngineError.insufficientData
      }
      return self[range]
    }
  }

  subscript(safe range: PartialRangeUpTo<Index>) -> Data {
    get throws {
      guard range.upperBound < endIndex, range.upperBound > startIndex else {
        throw CryptoEngineError.insufficientData
      }
      return self[range]
    }
  }

  subscript(safe range: PartialRangeFrom<Index>) -> Data {
    get throws {
      guard range.lowerBound < endIndex, range.lowerBound > startIndex else {
        throw CryptoEngineError.insufficientData
      }
      return self[range]
    }
  }
}
