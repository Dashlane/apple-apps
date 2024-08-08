import Combine
import CorePersonalData
import DashTypes
import Foundation
import IconLibrary

extension DomainIconLibraryProtocol {
  public func icon(for credential: Credential, usingLargeImage: Bool) async throws -> Icon? {
    return try await icon(for: credential.url, usingLargeImage: usingLargeImage)
  }

  public func icon(for url: PersonalDataURL?, usingLargeImage: Bool) async throws -> Icon? {
    guard let domain = url?.domain else {
      return nil
    }

    return try await icon(for: domain, format: .iOS(large: usingLargeImage))
  }

  public func icon(for url: PersonalDataURL?) async throws -> Icon? {
    return try await icon(for: url, usingLargeImage: false)
  }
}
