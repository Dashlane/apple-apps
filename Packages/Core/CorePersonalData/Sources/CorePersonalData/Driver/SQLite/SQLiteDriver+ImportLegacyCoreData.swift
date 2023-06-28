import Foundation
import DashTypes
import SwiftTreats

public enum ImportCoreDataError: Error {
    case expectingArrayOfDictionary
    case expectingStringDictionaryKey
    case cannotDecodeJsonProperty(key: String)
}

extension SQLiteDriver {
        public func importLegacyCoreData(at url: URL) throws {
        try write { db in
                        guard try db.count(for: .settings) == 0 else {
                return
            }

            let storeData = try Data(contentsOf: url)
                .decrypt(using: cryptoEngine)

            guard let nodes = try JSONSerialization.jsonObject(with: storeData, options: []) as? [NSDictionary] else {
                throw ImportCoreDataError.expectingArrayOfDictionary
            }

            for node in nodes {
                                                                                guard let object = try PersonalDataObject(coreDataNode: node),
                      let id = object.id.map({ Identifier($0) }),
                      let xmlType = object.type,
                      let contentType = PersonalDataContentType(xmlDataType: xmlType) else {
                          continue
                      }

                                let metadata = try RecordMetadata(id: id,
                                                  contentType: contentType,
                                                  coreDataCollection: object.content)

                let record = PersonalDataRecord(metadata: metadata,
                                                content: object.content.filter {
                    !CoreDataMetadataKeys.contains($0.key) 
                })

                                let shouldCreateSnapshot: Bool
                if let previousValues = object.content[.unsyncedValues]?.collection {
                    var snapshot = PersonalDataSnapshot(id: id, content: record.content)
                    snapshot.content = record.content.merging(previousValues, uniquingKeysWith: { _, snapshot in
                        snapshot
                    })
                    try db.insert(snapshot)
                    shouldCreateSnapshot = false
                } else {
                    shouldCreateSnapshot = true
                }

                                try db.insert(record, shouldCreateSnapshot: shouldCreateSnapshot)
            }
        }
    }
}

private extension PersonalDataObject {
    enum NodeKey: String {
        case entityName
        case propertyCache
    }
        init?(coreDataNode: NSDictionary) throws {
        let name = coreDataNode[.entityName] as? String
        guard let entityName = name,
              let propertyCache = coreDataNode[.propertyCache] as? NSDictionary,
              let id = propertyCache["id"] as? String,
              !id.isEmpty else {
                  return nil
              }

        let content = try PersonalDataCollection(propertyCache: propertyCache)
        self.init(type: .init(rawValue: entityName), content: content)
    }
}

private extension NSDictionary {
    subscript(key: PersonalDataObject.NodeKey) -> Any? {
        return self[key.rawValue]
    }
}

private protocol PropertyKey: RawRepresentable { }

private extension PropertyKey {
    static func contains(_ key: RawValue) -> Bool {
        Self.init(rawValue: key) != nil
    }
}

private extension PersonalDataCollection {
        init(propertyCache: NSDictionary) throws {
        self.init(minimumCapacity: propertyCache.count)

        for (key, value) in propertyCache {
            guard let keyString = key as? String else {
                throw ImportCoreDataError.expectingStringDictionaryKey
            }
            let key = keyString.lowercasingFirstLetter()

            if let dict = value as? NSDictionary {
                guard let object = try PersonalDataObject(coreDataNode: dict) else {
                    continue
                }
                self[key] = .object(object)
            } else if let array = value as? [NSDictionary] {
                let values: [PersonalDataValue] = try array
                    .compactMap { try PersonalDataObject(coreDataNode: $0) }
                    .map { .object($0) }

                self[key] = .list(values)
            } else if let value = value as? String, !value.isEmpty, let parsed: PersonalDataValue = try? .make(propertyKey: key, coreDataValue: value) {
                self[key] = parsed
            }
        }

                if let unknownDataString = self[.unknownData]?.item {
            let xmlParser = PersonalDataXMLParser()
                        guard let xmlData = """
                       <?xml version="1.0" encoding="utf-8"?>
                       <root>
                          <KWUnknown>
                             \(unknownDataString)
                          </KWUnknown>
                       </root>
                       """.data(using: .utf8) else {
                           return
                       }

            let object = try xmlParser.parse(xmlData)

            self.merge(object.content) { existingValue, _ in
                existingValue
            }
        }
    }
}

extension PersonalDataList {
        init?(jsonDictionaryArray: String) {
        guard let jsonData = jsonDictionaryArray.data(using: .utf8),
              let dictionaryArray = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [NSDictionary],
              let list: PersonalDataList = try? dictionaryArray.map({ dict in
                      .collection(try .init(propertyCache: dict))
              }) else {
                  return nil
              }

        self = list
    }

        init?(jsonStringArray: String) {
        guard let jsonData = jsonStringArray.data(using: .utf8),
              let stringArray = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String] else {
                  return nil
              }

        self = stringArray.map { string in
                .item(string)
        }
    }
}

extension PersonalDataCollection {
        init?(jsonDictionary: String) {
        guard let jsonData = jsonDictionary.data(using: .utf8),
              let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary else {
                  return nil
              }

        try? self.init(propertyCache: dictionary)
    }
}

private extension PersonalDataValue {
        enum JSONCollectionListKeys: String, PropertyKey {
        case trustedUrlGroup
    }

        enum JSONStringListKeys: String, PropertyKey {
        case changedProperties
        case banishedUrlsList
    }

        enum JSONCollectionKeys: String, PropertyKey {
        case currentData
        case unsyncedValues
    }

            static func make(propertyKey: String, coreDataValue value: String) throws -> PersonalDataValue {
        if JSONCollectionListKeys.contains(propertyKey) {
            guard let list = PersonalDataList(jsonDictionaryArray: value) else {
                throw ImportCoreDataError.cannotDecodeJsonProperty(key: propertyKey)
            }

            return .list(list)
        } else if JSONStringListKeys.contains(propertyKey) {
            guard let list = PersonalDataList(jsonStringArray: value) else {
                throw ImportCoreDataError.cannotDecodeJsonProperty(key: propertyKey)
            }

            return .list(list)
        } else if JSONCollectionKeys.contains(propertyKey) {
            guard let collection = PersonalDataCollection(jsonDictionary: value) else {
                throw ImportCoreDataError.cannotDecodeJsonProperty(key: propertyKey)
            }

            return .collection(collection)
        } else {
            return .item(value)
        }
    }
}

private extension RecordMetadata {
    struct CoreDataMetadata: Decodable {
        let backupDate: String?
        let syncStatusValue: RecordMetadata.SyncStatus?
        let syncId: String?
        let sharingSyncId: String?
        let lastLocalUseDate: Date?
        let lastLocalSearchDate: Date?
        let sharedObject: Bool
        let objectId: String?

        var lastSyncTimestamp: Timestamp? {
            guard let backupDate = backupDate, !backupDate.isEmpty else {
                return nil
            }
            return Timestamp(string: backupDate)
        }
    }

        init(id: Identifier,
         contentType: PersonalDataContentType,
         coreDataCollection: PersonalDataCollection) throws {
        let decoder = PersonalDataDecoder()
        let localMetadata = try decoder.decode(CoreDataMetadata.self, from: .collection(coreDataCollection))

        self.init(id: id,
                  contentType: contentType,
                  lastSyncTimestamp: localMetadata.lastSyncTimestamp,
                  syncStatus: localMetadata.syncStatusValue,
                  syncRequestId: localMetadata.syncId,
                  isShared: localMetadata.sharedObject,
                  pendingSharingUploadId: localMetadata.sharingSyncId,
                  parentId: localMetadata.objectId.map { Identifier($0) },
                  lastLocalUseDate: localMetadata.lastLocalUseDate,
                  lastLocalSearchDate: localMetadata.lastLocalSearchDate)
    }
}

private enum CoreDataMetadataKeys: String, PropertyKey {
    case backupDate
    case sharedBackupDate
    case unknownData
    case unsyncedValues
    case syncStatusValue
    case syncId
    case sharingSyncId
    case lastLocalUseDate
    case lastLocalSearchDate
}

private extension NSDictionary {
    subscript(key: CoreDataMetadataKeys) -> Any? {
        return self[key.rawValue]
    }
}

private extension PersonalDataCollection {
    subscript(key: CoreDataMetadataKeys) -> PersonalDataValue? {
        return self[key.rawValue]
    }
}
