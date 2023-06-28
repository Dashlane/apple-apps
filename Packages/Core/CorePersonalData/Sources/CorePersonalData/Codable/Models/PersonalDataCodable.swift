import Foundation
import DashTypes

public struct ItemValidationError: Error {
    public let invalidProperty: AnyKeyPath
}

public protocol PersonalDataCodable: Codable {
        static var contentType: PersonalDataContentType { get }

        static var xmlRuleExceptions: [String: XMLRuleException] { get }

        var metadata: RecordMetadata { get }

        var id: Identifier { get }

                    func validate() throws

                mutating func prepareForSaving()
}

public extension PersonalDataCodable {
        var isSaved: Bool {
        return !metadata.id.isTemporary
    }
}

public extension PersonalDataCodable {
    static var xmlRuleExceptions: [String: XMLRuleException] {
        [:]
    }

    func validate() throws {
            }

    func prepareForSaving() {
            }

        mutating func prepareForSavingAndValidate() throws {
        prepareForSaving()
        try validate()
    }

        var isValid: Bool {
        do {
            try validate()
            return true
        } catch {
            return false
        }
    }
}
