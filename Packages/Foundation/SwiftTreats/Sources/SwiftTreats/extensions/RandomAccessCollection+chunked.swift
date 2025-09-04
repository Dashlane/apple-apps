import Foundation

extension RandomAccessCollection where Index == Int {
  public func chunked(into size: Int) -> [[Element]] {
    guard size > 0 && count > 0 else {
      return []
    }

    guard size <= count else {
      return [Array(self)]
    }

    return stride(from: 0, to: count, by: size).map {
      Array(self[$0..<Swift.min($0 + size, count)])
    }
  }
}
