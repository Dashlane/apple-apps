import CoreTypes
import Foundation

extension Settings {
  public func makeTransactionContent() throws -> Data {
    let content = try PersonalDataEncoder().encode(self)
    let record = PersonalDataRecord(
      metadata: .init(id: id, contentType: .settings),
      content: content)
    return
      try record
      .compressedXMLData()
  }

  public static func makeSettings(compressedContent: Data) throws -> Settings {
    let record = try PersonalDataRecord(id: Settings.id, compressedXMLData: compressedContent)
    return try PersonalDataDecoder().decode(Settings.self, from: record)
  }
}
