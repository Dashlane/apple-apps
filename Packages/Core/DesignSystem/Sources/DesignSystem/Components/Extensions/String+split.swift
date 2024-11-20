import Foundation

extension String {
  func split(by chunkLength: Int) -> [String] {
    var startIndex = startIndex
    var substrings = [Substring]()

    while startIndex < endIndex {
      let endIndex = index(startIndex, offsetBy: chunkLength, limitedBy: endIndex) ?? endIndex
      substrings.append(self[startIndex..<endIndex])
      startIndex = endIndex
    }

    return substrings.map(String.init)
  }

  func split(byChunks chunks: [Int]) -> [String] {
    var currentIndex = 0
    var result = [String]()
    for chunk in chunks {
      let chunk = String(dropFirst(currentIndex).prefix(chunk))
      currentIndex += chunk.count
      result.append(chunk)
    }
    return result
  }
}
