import CoreTypes
import Foundation
import LogFoundation
import StoreKit

extension PersonalDataRecord {
  @Loggable
  public enum TransactionError: Error {
    @LogPublicPrivacy
    case unknownContentType(_ type: String)
  }

  init(id: Identifier, compressedXMLData: Data) throws {
    let data =
      try compressedXMLData
      .decompressQtCompressedData()

    let parser = PersonalDataXMLParser()
    let object = try parser.parse(data)

    try self.init(id: id, personalDataObject: object)
  }

  init(id: Identifier, personalDataObject: PersonalDataObject) throws {
    guard let xmlType = personalDataObject.type,
      let type = PersonalDataContentType(xmlDataType: xmlType)
    else {
      throw TransactionError.unknownContentType(personalDataObject.$type)
    }
    let metadata = RecordMetadata(
      id: id,
      contentType: type,
      parentId: personalDataObject.content[.objectId].map { Identifier($0) })
    self.init(
      metadata: metadata,
      content: personalDataObject.content)

    if type != .settings {
      self[.id] = id.rawValue
    }
  }

  public func compressedXMLData() throws -> Data {
    try makeXML()
      .toQtCompressedData()
  }
}

extension Array where Element == PersonalDataRecord {
  init(compressedBackupXMLData: Data) throws {
    let data =
      try compressedBackupXMLData
      .decompressQtCompressedData()

    let parser = PersonalDataXMLParser()
    let objects = try parser.parseFullBackup(data)

    self = try objects.compactMap { object in
      do {
        guard let id = object.id else {
          return nil
        }

        return try .init(id: Identifier(id), personalDataObject: object)
      } catch PersonalDataRecord.TransactionError.unknownContentType {
        return nil
      }
    }
  }
}
