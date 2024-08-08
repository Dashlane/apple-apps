import DashTypes
import Foundation

extension ApplicationDBStack {
  public func checkShareability(of itemIds: [Identifier]) throws {
    let records = try driver.read {
      try $0.fetchAll(with: itemIds)
    }

    let isAllItemsSharable = records.allSatisfy {
      $0.metadata.isShareable
    }

    if !isAllItemsSharable {
      throw ShareabilityError.itemNotShareable
    }

    let hasAttachments = try records.contains {
      let item = try decoder.decode(AnyDocumentAttachable.self, from: $0)
      return item.attachments?.isEmpty == false
    }

    if hasAttachments {
      throw ShareabilityError.cannotShareWithAttachments
    }
  }
}

public enum ShareabilityError: Error {
  case cannotShareWithAttachments
  case itemNotShareable
}
