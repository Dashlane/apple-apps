import CorePersonalData
import CorePremium
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation

struct TeamSpaceRevokeHandler {
  let database: ApplicationDatabase
  let sharingService: SharingServiceProtocol
  let apiClient: UserDeviceAPIClient.Teams
  let cloudPasskeysService: UserSecureNitroEncryptionAPIClient.Passkeys
  let logger: Logger

  func callAsFunction(for status: CorePremium.Status) async throws {
    guard let pastTeams = status.b2bStatus?.pastTeams else {
      return
    }

    for pastTeam in pastTeams where pastTeam.teamInfo.shouldDeleteItemsOnRevoke {
      try await handleRevoke(on: pastTeam)
    }
  }

  private func handleRevoke(on team: CorePremium.Status.B2bStatus.PastTeamsElement) async throws {
    do {
      let sharedItems = try database.fetchAll(
        PersonalDataContentType.allCases.filter { $0.sharingType != nil },
        in: team)
      try await sharingService.forceRevoke(sharedItems)

      if team.shouldDelete == true {
        let passkeys = try database.fetchAll(Passkey.self, in: team)
        try await cloudPasskeysService.deleteIfNeeded(passkeys, logger: logger)

        let itemsToDelete = try database.fetchAll(
          PersonalDataContentType.allCases,
          in: team,
          prefetchedPasskeys: passkeys)
        try database.delete(itemsToDelete)

        _ = try await apiClient.spaceDeleted(teamId: team.teamId)
      }
    } catch let error as APIError {
      logger.fatal("Failed to handle revoke on team \(team.teamId)", error: error)
    } catch {
      logger.error("Failed to handle revoke on team \(team.teamId)", error: error)
    }
  }
}

extension ApplicationDatabase {
  fileprivate func fetchAll<Output: VaultItem>(
    _ type: Output.Type,
    in team: CorePremium.Status.B2bStatus.PastTeamsElement
  ) throws -> [Output] {
    try fetchAll(Output.self).filter {
      $0.spaceId == team.personalDataId || $0.isAssociated(to: team.teamInfo)
    }
  }

  fileprivate func fetchAll(
    _ types: [PersonalDataContentType],
    in team: CorePremium.Status.B2bStatus.PastTeamsElement,
    prefetchedPasskeys: [Passkey] = []
  ) throws -> [PersonalDataCodable] {
    try PersonalDataContentType.allCases.flatMap { type -> [PersonalDataCodable] in
      switch type {
      case .credential:
        return try fetchAll(Credential.self, in: team)

      case .passkey:
        return prefetchedPasskeys

      case .secureNote:
        return try fetchAll(SecureNote.self, in: team)

      case .creditCard:
        return try fetchAll(CreditCard.self, in: team)
      case .bankAccount:
        return try fetchAll(BankAccount.self, in: team)

      case .email:
        return try fetchAll(Email.self, in: team)
      case .website:
        return try fetchAll(PersonalWebsite.self, in: team)
      case .address:
        return try fetchAll(Address.self, in: team)
      case .company:
        return try fetchAll(Company.self, in: team)
      case .phone:
        return try fetchAll(Phone.self, in: team)

      case .identity:
        return try fetchAll(Identity.self, in: team)
      case .idCard:
        return try fetchAll(IDCard.self, in: team)
      case .driverLicence:
        return try fetchAll(DrivingLicence.self, in: team)
      case .passport:
        return try fetchAll(Passport.self, in: team)

      case .socialSecurityInfo:
        return try fetchAll(Address.self, in: team)
      case .taxNumber:
        return try fetchAll(FiscalInformation.self, in: team)

      case .collection:
        return try fetchAll(PrivateCollection.self).filter(spaceId: team.personalDataId).map {
          $0 as PersonalDataCodable
        }

      case .generatedPassword, .credentialCategory, .secureNoteCategory, .securityBreach, .settings,
        .dataChangeHistory, .secureFileInfo:
        return []
      case .secret:
        return try fetchAll(Secret.self, in: team)
      case .wifi:
        return try fetchAll(WiFi.self, in: team)
      }
    }
  }
}

extension UserSecureNitroEncryptionAPIClient.Passkeys {
  fileprivate func deleteIfNeeded(_ passkeys: [Passkey], logger: Logger) async throws {
    for passkey in passkeys {
      guard let mode = try? passkey.mode, case let Passkey.Mode.cloud(cloudPasskey) = mode else {
        continue
      }

      do {
        try await deletePasskey(
          passkeyId: cloudPasskey.passkeyId, encryptionKey: cloudPasskey.encryptionKey)
      } catch let error as NitroEncryptionError {
        logger.fatal("Can't delete cloud passkey \(passkey.id) during team revoke", error: error)
      }
    }
  }
}
