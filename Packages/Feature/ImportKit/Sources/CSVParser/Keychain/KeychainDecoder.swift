import Foundation

enum KeychainHeader: String, CaseIterable, CSVHeader {

    case title = "Title"
    case url = "URL"
    case username = "Username"
    case password = "Password"
    case notes = "Notes"
    case otpAuth = "OTPAuth"

    var isOptional: Bool {
        switch self {
        case .title, .url, .username, .password:
            return false
        case .notes, .otpAuth:
            return true
        }
    }

}

public struct KeychainDecoder {

                public static func decode(fileContent: Data) throws -> [KeychainCredential] {
        let csvParser = CSVParser(delimiter: ",", headers: KeychainHeader.allCases)
        let csvContent = try csvParser.parse(fileContent: fileContent)

        return csvContent.compactMap { .init(csvContent: $0) }
    }

}
