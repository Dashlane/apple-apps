import DashTypes
import Foundation

struct SharingUploadTrigger {
  func update(
    _ metadata: inout RecordMetadata,
    for newContent: PersonalDataCollection,
    oldContent: PersonalDataCollection
  ) {
    guard metadata.isShared else {
      return
    }

    let needsSharing =
      oldContent.isEmpty
      ? true
      : metadata
        .contentType
        .sharedPropertyKeys
        .contains {
          newContent[$0] != oldContent[$0]
        }

    guard needsSharing else {
      return
    }

    metadata.pendingSharingUploadId = UUID().uuidString
  }
}
