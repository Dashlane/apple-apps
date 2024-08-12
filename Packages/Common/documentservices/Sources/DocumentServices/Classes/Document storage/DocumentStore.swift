import CorePersonalData
import DashTypes

public protocol DocumentStore {
  func save<ItemType: PersonalDataCodable>(_ item: ItemType) throws -> ItemType
  func delete(_ data: PersonalDataCodable) throws
  func fetch<Output: PersonalDataCodable>(with id: Identifier, type: Output.Type) throws -> Output?
  func save(_ item: DocumentAttachable) throws
}
