import DashTypes
import Foundation
import SwiftTreats

@PersonalData("DATA_CHANGE_HISTORY")
struct DataChangeHistory {
  struct ChangeSet: NestedObject, Codable, Equatable {
    enum CodingKeys: String, CodingKey {
      case id
      case changedKeys = "properties"
      case previousRecordContent = "currentData"
      case modificationDate
      case removed
      case platform
      case deviceName
      case user
    }

    static let contentType: XMLDataType = .dataChangeSets

    let id: Identifier

    let changedKeys: Set<String>
    @Defaulted
    var previousRecordContent: PersonalDataCollection
    let modificationDate: Date?

    let removed: Bool

    let platform: String
    let deviceName: String
    let user: String

    internal init(
      id: Identifier,
      changedKeys: Set<String>,
      previousRecordContent: PersonalDataCollection,
      modificationDate: Date?,
      removed: Bool,
      platform: String,
      deviceName: String,
      user: String
    ) {
      self.id = id
      self.changedKeys = changedKeys
      self._previousRecordContent = .init(previousRecordContent)
      self.modificationDate = modificationDate
      self.removed = removed
      self.platform = platform
      self.deviceName = deviceName
      self.user = user
    }

  }

  let objectId: Identifier
  var objectTitle: String?
  let objectType: PersonalDataContentType

  var changeSets: [ChangeSet]

  init(
    id: Identifier,
    objectId: Identifier,
    objectTitle: String? = nil,
    objectType: PersonalDataContentType,
    metadata: RecordMetadata,
    changeSets: [ChangeSet]
  ) {
    self.id = id
    self.objectId = objectId
    self.objectTitle = objectTitle
    self.objectType = objectType
    self.metadata = metadata
    self.changeSets = changeSets
  }
}
