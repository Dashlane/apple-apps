import Foundation

extension PersonalDataRecord {
  mutating func mergeSharedContent(_ sharedContent: PersonalDataCollection) -> Bool {
    let sharedProperties = self.metadata.contentType.sharedPropertyKeys
    let sharedValues = sharedContent.filter {
      sharedProperties.contains($0.key) && self.content[$0.key] != $0.value
    }
    guard !sharedValues.isEmpty else {
      return false
    }

    for (key, value) in sharedValues {
      content[key] = value
    }

    return true
  }
}
