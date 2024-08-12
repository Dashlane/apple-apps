import DashTypes
import Foundation
import SwiftTreats

extension PersonalDataRecord {
  func makeXML() throws -> Data {
    let type = XMLDataType(metadata.contentType)
    let exceptions = metadata.contentType.personalDataType.xmlRuleExceptions
    let data = """
      <?xml version=\"1.0\" encoding=\"UTF-8\"?><root><\(type.rawValue)>\(content.makeXML(exceptions: exceptions))</\(type.rawValue)></root>
      """.data(using: .utf8)

    guard let data = data else {
      throw PersonalDataRecord.TransactionError.cannotCreateUTF8DataFromXML
    }

    return data
  }
}

extension Sequence where Element == PersonalDataRecord {
  func makeXML() throws -> Data {
    let items: String = self.map { item in
      let type = XMLDataType(item.metadata.contentType)
      let exceptions = item.metadata.contentType.personalDataType.xmlRuleExceptions

      return "<\(type.rawValue)>\(item.content.makeXML(exceptions: exceptions))</\(type.rawValue)>"
    }.joined()

    let data = """
      <?xml version=\"1.0\" encoding=\"UTF-8\"?><root><KWDataList>\(items)</KWDataList></root>
      """.data(using: .utf8)

    guard let data = data else {
      throw PersonalDataRecord.TransactionError.cannotCreateUTF8DataFromXML
    }

    return data
  }
}

extension PersonalDataValue {
  func makeSuffix(for key: String?) -> String {
    guard let key = key else {
      return ""
    }

    return #" key="\#(key)""#
  }

  func makeXML(key: String? = nil, keyCase: XMLKeyCase) -> String {
    let key = makeSuffix(for: key)

    switch self {
    case let .item(item):
      return """
        <KWDataItem\(key)><![CDATA[\(item)]]></KWDataItem>
        """

    case let .list(list):
      return """
        <KWDataList\(key)>\(list.makeXML(keyCase: keyCase))</KWDataList>
        """

    case let .collection(dict):
      return """
        <KWDataCollection\(key)>\(dict.makeXML(keyCase: keyCase))</KWDataCollection>
        """

    case let .object(object):
      return """
        <\(object.$type)\(key)>\(object.content.makeXML(keyCase: keyCase))</\(object.$type)>
        """
    }
  }
}

extension PersonalDataCollection {
  fileprivate func makeXML(exceptions: [String: XMLRuleException]) -> String {
    self.compactMap { key, value in
      let exception = exceptions[key]
      guard exception != .skip else {
        return nil
      }

      return value.makeXML(
        key: key.applying(exception?.keyCase ?? .default),
        keyCase: exception?.childKeyCase ?? .default)
    }.joined()
  }

  fileprivate func makeXML(keyCase: XMLKeyCase) -> String {
    self.compactMap { key, value in
      return value.makeXML(key: key.applying(keyCase), keyCase: keyCase)
    }.joined()
  }
}

extension PersonalDataList {
  fileprivate func makeXML(keyCase: XMLKeyCase) -> String {
    self.map { value in
      value.makeXML(keyCase: keyCase)
    }.joined()
  }
}
