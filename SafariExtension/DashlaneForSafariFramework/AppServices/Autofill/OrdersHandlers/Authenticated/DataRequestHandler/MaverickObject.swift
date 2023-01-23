import Foundation
import CorePersonalData

class MaverickObject {
    static var dictionaryEncoder = DictionaryEncoder(dateEncodingStrategy: .secondsSince1970, keyEncodingStrategyKey: .uppercaseFirstCharacter)
    
            static func toDictionaryWithUppercaseKeys<T: Encodable>(object: T) -> [String: Any]? {
        do {
            return try dictionaryEncoder.encode(object)
                .mapValues { mapToMaverickValue($0) }
                .filter { $0.key != "Metadata"}
        } catch {
            return nil
        }
    }
    
   private static func mapToMaverickValue(_ value: Any) -> Any {
        switch value {
            case let value as [Any]:
                return value.map { mapToMaverickValue($0) }
            case let value as [String: Any]:
                return value.mapValues { mapToMaverickValue($0) }
            case let value as Date:
                return String(Int(value.timeIntervalSince1970))
            default:
                return "\(value)"
        }
    }
    
        static func addCountryField(to address: [String: Any]) -> [String: Any] {
        let localeFormatKey = "LocaleFormat"
        if let localeFormat = address[localeFormatKey] as? String {
            var updatedAddress = address
            updatedAddress[localeFormatKey] = localeFormat.localizedLowercase
            updatedAddress["Country"] = localeFormat.localizedLowercase
            return updatedAddress
        }
        return address
    }

                static func addPersonalSpaceIDIfNeeded(to object: [String: Any], hasSpaces: Bool) -> [String: Any] {
        guard hasSpaces else { return object }
        var mutableObject = object
        if mutableObject["SpaceId"] == nil {
            mutableObject["SpaceId"] = ""
        }
        return mutableObject
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }

    func lowercasingFirstLetter() -> String {
        prefix(1).lowercased() + dropFirst()
    }
}
