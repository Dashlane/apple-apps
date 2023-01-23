import Foundation
import SwiftTreats
import DashTypes

extension PersonalDataRecord {
        func makeXML() throws -> Data {
        let type = XMLDataType(metadata.contentType)
        let data = """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?><root><\(type.rawValue)>\(content.makeXML())</\(type.rawValue)></root>
        """.data(using: .utf8)
        
        guard let data = data else {
            throw PersonalDataRecord.TransactionError.cannotCreateUTF8DataFromXML
        }
        
        return data
    }
}

extension Sequence where Element == PersonalDataRecord {
        func makeXML() throws -> Data {
        let objects = self.map {
           PersonalDataObject(type: .init($0.metadata.contentType), content: $0.content)
        }
        let list = PersonalDataValue.list(PersonalDataList(objects))
        
        let data = """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?><root>\(list.makeXML())</root>
        """.data(using: .utf8)
        
        guard let data = data else {
            throw PersonalDataRecord.TransactionError.cannotCreateUTF8DataFromXML
        }
        
        return data
    }
}

extension PersonalDataValue {
    func makeSuffix(for key: String?) -> String {
        guard var key = key else {
            return ""
        }
        
        key = key == "accountCreationDatetime" ? key : key.capitalizingFirstLetter()
        
        return #" key="\#(key)""#
    }
    
    func makeXML(key: String? = nil) -> String {
        let key = makeSuffix(for: key)

        switch self {
            case let .item(item):
                return """
                    <KWDataItem\(key)><![CDATA[\(item)]]></KWDataItem>
                    """
                
            case let .list(list):
                return """
                    <KWDataList\(key)>\(list.makeXML())</KWDataList>
                    """

            case let .collection(dict):
                return """
                    <KWDataCollection\(key)>\(dict.makeXML())</KWDataCollection>
                    """
                
            case let .object(object):
                return """
                    <\(object.$type)\(key)>\(object.content.makeXML())</\(object.$type)>
                    """
        }
    }
}


fileprivate extension PersonalDataCollection {
                        static let ignoredKeys: [String] = [
        Credential.CodingKeys.manualAssociatedDomains.stringValue
    ]
    
    func makeXML() -> String {
        self.compactMap { key, value in
            guard !Self.ignoredKeys.contains(key) else {
                return nil
            }
            return value.makeXML(key: key)
        }.joined()
    }
}

fileprivate extension PersonalDataList {
    func makeXML() -> String {
         self.map { value in
            value.makeXML()
        }.joined()
    }
}
