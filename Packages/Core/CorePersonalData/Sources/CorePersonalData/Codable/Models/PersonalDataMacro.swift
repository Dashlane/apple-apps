import CoreTypes
import Foundation

@attached(
  member,
  conformances: HistoryChangePreviousContent,
  names: named(PreviousChangeContent), named(metadata), named(id), named(contentType))
@attached(
  extension,
  conformances: PersonalDataCodable, Searchable, HistoryChangeTracking, SecureItem,
  names: named(CodingKeys), named(xmlRuleExceptions), named(searchValues))
macro PersonalData(_ type: String? = nil) =
  #externalMacro(module: "PersonalDataMacros", type: "PersonalDataMacro")

@attached(peer)
macro CodingKey(_ key: String) =
  #externalMacro(module: "PersonalDataMacros", type: "CodingKeyAttribute")

@attached(peer)
macro OnSync(_ exeption: XMLRuleException) =
  #externalMacro(module: "PersonalDataMacros", type: "OnSyncAttribute")

@attached(peer)
macro Searchable() = #externalMacro(module: "PersonalDataMacros", type: "SearchableAttribute")
