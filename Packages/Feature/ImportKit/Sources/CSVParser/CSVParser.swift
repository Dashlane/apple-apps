import Foundation
import LogFoundation

public struct CSVParser {

  public enum Error: Swift.Error {

    case fileDecodingFailed

    case headerMismatch

    case missingClosingQuote

  }

  private let delimiter: Character
  private let expectedHeaders: [CSVHeader]
  private let quote: Character = "\""

  public init(delimiter: Character, headers: [CSVHeader]) {
    self.delimiter = delimiter
    self.expectedHeaders = headers
  }

  private func values(for line: [String], with headers: [String]) -> [String: String]? {
    guard line.count == headers.count else {
      return nil
    }

    var result: [String: String] = [:]
    line.enumerated().forEach { indexValue, columnValue in
      result[headers[indexValue]] = columnValue
    }
    return result
  }

  public func parse(fileContent: Data, encoding: String.Encoding = .utf8) throws -> [[String:
    String]]
  {
    guard let fileContent: String = String(data: fileContent, encoding: encoding) else {
      throw Error.fileDecodingFailed
    }

    var lines = parseCSV(contents: fileContent)

    guard !lines.isEmpty else {
      return []
    }

    let headers = lines.removeFirst()

    guard
      expectedHeaders.allSatisfy({ header in
        header.isOptional ? true : headers.contains(where: { header.rawValue == $0 })
      })
    else {
      throw Error.headerMismatch
    }

    return lines.compactMap { values(for: $0, with: headers) }
  }

  func parseCSV(contents: String) -> [[String]] {
    var result: [[String]] = []
    var currentRow: [String] = []
    var currentColumn = ""
    var isInQuote = false
    var skipNextIteration = false

    for (index, character) in contents.enumerated() {
      guard !skipNextIteration else {
        skipNextIteration = false
        continue
      }
      switch character {
      case "\"":
        if isInQuote {
          if contents[index + 1] == "," {
            isInQuote = false
            skipNextIteration = true
            currentRow.append(currentColumn)
            currentColumn = ""
          } else {
            currentColumn.append(character)
          }
        } else {
          isInQuote = true
        }
      case ",":
        if isInQuote {
          currentColumn.append(character)
        } else {
          currentRow.append(currentColumn)
          currentColumn = ""
        }
      case "\n":
        if isInQuote {
          currentColumn.append(character)
        } else {
          currentRow.append(currentColumn)
          result.append(currentRow)
          currentRow = []
          currentColumn = ""
        }
      default:
        currentColumn.append(character)
      }
    }

    if !currentRow.isEmpty || !currentColumn.isEmpty {
      currentRow.append(currentColumn)
      result.append(currentRow)
    }
    return result
  }
}

extension String {
  subscript(index: Int) -> String {
    return self[index..<index + 1]
  }

  subscript(range: Range<Int>) -> String {
    let localRange = Range(
      uncheckedBounds: (
        lower: max(0, min(count, range.lowerBound)),
        upper: min(count, max(0, range.upperBound))
      ))
    let start = index(startIndex, offsetBy: localRange.lowerBound)
    let end = index(start, offsetBy: localRange.upperBound - localRange.lowerBound)
    return String(self[start..<end])
  }
}
