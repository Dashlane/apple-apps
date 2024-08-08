import Foundation

extension PersonalDataValue {
  func merging(withRemoteValue remoteValue: PersonalDataValue, snapshotValue: PersonalDataValue?)
    -> PersonalDataValue
  {

    switch (self, remoteValue) {
    case (_, .item):
      guard snapshotValue != remoteValue else {
        return self
      }
      return remoteValue
    case let (.list(value), .list(remote)):
      return .list(value.merging(withRemoteList: remote, snapshotList: snapshotValue?.list ?? []))
    case let (.collection(collection), .collection(remoteCollection)):
      return .collection(
        collection.merging(
          withRemoteCollection: remoteCollection,
          snapshotCollection: snapshotValue?.collection ?? [:]))
    case let (.object(object), .object(remoteObject)):
      guard object.$type == remoteObject.$type,
        object.id != nil,
        object.id == remoteObject.id
      else {
        return remoteValue
      }
      let newObject = object.merging(
        withRemoteObject: remoteObject, snapshotObject: snapshotValue?.object)
      return .object(newObject)
    default:
      return remoteValue
    }
  }
}

extension PersonalDataObject {
  func merging(withRemoteObject remoteObject: Self, snapshotObject: Self?) -> Self {
    let content = content.merging(
      withRemoteCollection: remoteObject.content, snapshotCollection: snapshotObject?.content ?? [:]
    )
    return Self(type: .init(rawValue: $type), content: content)
  }
}

extension PersonalDataCollection {
  func merging(
    withRemoteCollection remoteCollection: PersonalDataCollection,
    snapshotCollection: PersonalDataCollection
  ) -> PersonalDataCollection {
    guard snapshotCollection != remoteCollection else {
      return self
    }
    let keys = Set(remoteCollection.keys).union(self.keys)
    var mergedContent = PersonalDataCollection()
    for key in keys {
      if let local = self[key], let remote = remoteCollection[key] {
        mergedContent[key] = local.merging(
          withRemoteValue: remote, snapshotValue: snapshotCollection[key])
      } else if let remote = remoteCollection[key], remote != snapshotCollection[key] {
        mergedContent[key] = remote
      } else if let local = self[key], local != snapshotCollection[key],
        remoteCollection[key] != nil || remoteCollection[key] == snapshotCollection[key]
      {
        mergedContent[key] = local
      }
    }
    return mergedContent
  }
}

extension PersonalDataList {
  func merging(withRemoteList remoteList: PersonalDataList, snapshotList: PersonalDataList)
    -> PersonalDataList
  {
    guard remoteList != snapshotList else {
      return self
    }

    let remoteObjectsByIds = Dictionary(grouping: remoteList.compactMap(\.object), by: \.id)
      .compactMapValues(\.first)
    let snapshotContentByIds = Dictionary(grouping: (snapshotList).compactMap(\.object), by: \.id)
      .compactMapValues(\.first)
    let localObjectsIds = Dictionary(grouping: (self).compactMap(\.object), by: \.id)
      .compactMapValues(\.first)

    if remoteObjectsByIds.isEmpty && localObjectsIds.isEmpty {
      return remoteList
    } else {
      var newList = remoteList.map { value -> PersonalDataValue in
        switch value {
        case let .object(remote):
          guard let local = localObjectsIds[remote.id] else {
            return value
          }
          return .object(
            local.merging(withRemoteObject: remote, snapshotObject: snapshotContentByIds[remote.id])
          )
        default:
          return value
        }
      }

      let localObjectsToInsert = localObjectsIds.filter {
        remoteObjectsByIds[$0.key] == nil && snapshotContentByIds[$0.key] == nil
      }
      .map { PersonalDataValue.object($0.value) }
      newList.append(contentsOf: localObjectsToInsert)

      return newList
    }
  }

}
