import Foundation

public enum LastpassHeader: String, CaseIterable, CSVHeader {

    public static let secureNotePrefix = "_"

    case url
    case username
    case password
    case totp
    case extra
    case name
    case grouping
    case fav

    public var isOptional: Bool {
        false
    }
}

public struct LastpassDecoder {

                public static func decode(fileContent: Data) throws -> [LastpassItem] {
        let csvParser = CSVParser(delimiter: ",", headers: LastpassHeader.allCases)
        let csvContent = try csvParser.parse(fileContent: fileContent)

        return csvContent.compactMap { .init(csvContent: $0) }
    }

}
