import Foundation

extension String {
  var recoveryKeyFormatted: String {
    let components = self.components(withMaxLength: 4)
    return components.joined(separator: "-")
  }

  func components(withMaxLength length: Int) -> [String] {
    return stride(from: 0, to: self.count, by: length).map {
      let start = self.index(self.startIndex, offsetBy: $0)
      let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
      return String(self[start..<end])
    }
  }
}
