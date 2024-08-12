import Foundation

extension DefaultStringInterpolation {
  public mutating func appendInterpolation(_ string: String, preserveIndentation: Bool) {
    guard preserveIndentation else {
      appendInterpolation(string)
      return
    }
    let indent = String(stringInterpolation: self).reversed().prefix { " \t".contains($0) }
    if indent.isEmpty {
      appendInterpolation(string)
    } else {
      appendLiteral(
        string.split(separator: "\n", omittingEmptySubsequences: false).joined(
          separator: "\n" + indent))
    }
  }
}
