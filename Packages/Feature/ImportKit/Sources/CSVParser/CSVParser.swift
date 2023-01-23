import Foundation

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

    private func values(for line: Substring, with headers: [Substring]) throws -> [String: String] {
        var results: [String: String] = [:]
        var builder: String = ""
        var enclosed = false
        var columnIndex = 0

        func addResult() throws {
            let header = expectedHeaders.first(where: { headers[columnIndex] == $0.rawValue })!
            results[header.rawValue] = try builder.unquote()
            builder.removeAll()
            columnIndex += 1
        }

        for character in line {
            if !enclosed, character == "\n" {
                break
            }

            if !enclosed, character == "\r" {
                continue
            }

            if !enclosed, character == delimiter {
                try addResult()
                continue
            }

            builder.append(character)

            if character == quote {
                enclosed.toggle()
            }
        }

        try addResult()

        return results
    }

                            public func parse(fileContent: Data, encoding: String.Encoding = .utf8) throws -> [[String: String]] {
        guard let fileContent: String = String(data: fileContent, encoding: encoding) else {
            throw Error.fileDecodingFailed
        }

        var lines = fileContent.split(whereSeparator: \.isNewline)

                guard !lines.isEmpty else {
            return []
        }

        let headers = lines.removeFirst().split(separator: delimiter)

                guard expectedHeaders.allSatisfy({ header in
            header.isOptional ? true : headers.contains(where: { header.rawValue == $0 })
        }) else {
            throw Error.headerMismatch
        }

        return try lines.map { try values(for: $0, with: headers) }
    }

}

private extension String {

    func unquote() throws -> String {
        let quote = "\""
        let trimmed = trimmingCharacters(in: .whitespaces)

        if trimmed.starts(with: quote) {
            guard trimmed.hasSuffix(quote) else {
                throw CSVParser.Error.missingClosingQuote
            }

            return trimmed
                .trimmingCharacters(in: CharacterSet(charactersIn: quote))
                .replacingOccurrences(of: "\(quote)\(quote)", with: quote)
        } else {
            return self
        }
    }

}
