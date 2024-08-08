import Foundation

extension Array {

  func splitInSubArrays(ofMaxLength maxLength: Int) -> [[Element]] {
    guard maxLength > 0 else { return [self] }
    return stride(from: 0, to: count, by: maxLength).map {
      Array(self[$0..<Swift.min($0 + maxLength, count)])
    }
  }
}
