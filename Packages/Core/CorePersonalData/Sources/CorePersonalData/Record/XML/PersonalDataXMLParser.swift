import Foundation
import DashTypes

final class PersonalDataXMLParser: NSObject {
        enum ParsingError: Error {
        case noNodeFound
        case noObjectFound
        case cannotConvertStringToData
        case objectEmpty
        case wrongContentType(result: String, expected: XMLDataType)
    }

    fileprivate struct Node {
        let type: NodeType
        let key: String?
        var value: String?
        var children: [Node] = []

        var firstChildren: Node? {
            return children.first
        }
    }

    fileprivate enum NodeType: Equatable {
        init(_ elementName: String) {
            switch elementName {
                case "KWDataItem":
                    self = .item
                case "KWDataCollection":
                    self = .collection
                case "KWDataList":
                    self = .list
                default:
                    self = .object(elementName)
            }
        }

        case item
        case collection
        case list
        case object(String)
    }

    fileprivate var nodes: [Node] = []

        private func performParse(_ xmlData: Data) throws {
        let parser = XMLParser(data: xmlData)
        parser.delegate = self
        parser.parse()
    }

    func parse(_ xmlData: Data, forTransactionType expectedType: PersonalDataContentType) throws -> PersonalDataCollection {
        let object = try parse(xmlData)

        let xmlType = XMLDataType(expectedType)
        guard xmlType == object.type else {
            throw ParsingError.wrongContentType(result: object.$type, expected: xmlType)
        }

        return object.content
    }

    func parse(_ xmlData: Data) throws -> PersonalDataObject {
        try performParse(xmlData)

                guard let objectNode = nodes.first?.children.first else {
            throw ParsingError.noObjectFound
        }

        let value = objectNode.syncedContentValue()
        guard case let .object(object) = value else {
            throw ParsingError.noObjectFound
        }

        nodes.removeAll()

        return object
    }

    func parseFullBackup(_ xmlData: Data) throws -> [PersonalDataObject] {
        try performParse(xmlData)

                guard let list = nodes.first?.firstChildren else {
            throw ParsingError.noNodeFound
        }

        nodes.removeAll()

        return Array(list.children).compactMap { value in
            guard case let .object(object) = value else {
                return nil
            }
            return object
        }
    }

    func parse(_ xmlString: String, forTransactionType expectedType: PersonalDataContentType) throws -> PersonalDataCollection {
        guard let data = xmlString.data(using: .utf8) else {
            throw ParsingError.cannotConvertStringToData
        }
        return try parse(data, forTransactionType: expectedType)
    }

    func parseFullBackup(_ xmlString: String) throws -> [PersonalDataObject] {
        guard let data = xmlString.data(using: .utf8) else {
            throw ParsingError.cannotConvertStringToData
        }
        return try parseFullBackup(data)
    }
}

extension PersonalDataXMLParser: XMLParserDelegate {
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        let key = attributeDict["key"]?.lowercasingFirstLetter()
        let type = NodeType(elementName)
        nodes.append(Node(type: type, key: key))
    }

    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        guard nodes.count > 1, let node = nodes.popLast() else {
            return
        }
        nodes[nodes.endIndex-1].children.append(node)
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard nodes.last?.type == .item, let string = String(data: CDATABlock, encoding: .utf8) else {
            return
        }
        nodes[nodes.endIndex-1].value = string
    }
}

private typealias Node =  PersonalDataXMLParser.Node
fileprivate extension Node {
    func syncedContentValue() -> PersonalDataValue? {
        switch type {
            case .item:
                guard let value = value else {
                    return nil
                }
                return .item(value)
            case .collection:
                return .collection(Dictionary(children))
            case .list:
                return .list(Array(children))
            case let .object(type):
                return .object(.init(type: .init(rawValue: type), content: Dictionary(children)))

        }
    }
}

fileprivate extension PersonalDataCollection {
    init(_ nodes: [Node]) {
        self.init(minimumCapacity: nodes.count)
        for node in nodes {
            guard let key = node.key, let value = node.syncedContentValue() else {
                continue
            }
            self[key] = value
        }
    }
}

fileprivate extension PersonalDataList {
    init(_ nodes: [Node]) {
        self.init(nodes.compactMap {
            $0.syncedContentValue()
        })
    }
}
