import Combine
import CorePersonalData
import DashTypes
import Foundation
import IconLibrary

extension DomainIconLibraryProtocol {
  public func icon(for credential: Credential) async throws -> Icon? {
    return try await icon(for: credential.url)
  }

  public func icon(for url: PersonalDataURL?) async throws -> Icon? {
    guard let domain = url?.domain else { return nil }
    return try await icon(for: domain)
  }
}
