import CorePersonalData
import CorePremium
import DashTypes
import DashlaneAPI
import Foundation

struct TeamSpaceRevokeHandler {
  let database: ApplicationDatabase
  let sharingService: SharingServiceProtocol
  let apiClient: UserDeviceAPIClient.Teams

  func callAsFunction(for status: CorePremium.Status) async throws {
    guard let pastTeams = status.b2bStatus?.pastTeams else {
      return
    }

    for pastTeam in pastTeams where pastTeam.teamInfo.shouldDeleteItemsOnRevoke {
      try await handleRevoke(on: pastTeam)
    }
  }

  private func handleRevoke(on team: CorePremium.Status.B2bStatus.PastTeamsElement) async throws {
    for sharedType in SharingType.allCases {
      switch sharedType {
      case .password:
        try await sharingService.forceRevoke(
          try database.fetchAll(Credential.self, in: team).filter { $0.isShared })
      case .note:
        try await sharingService.forceRevoke(
          try database.fetchAll(SecureNote.self, in: team).filter { $0.isShared })
      case .secret:
        try await sharingService.forceRevoke(
          try database.fetchAll(Secret.self, in: team).filter { $0.isShared })
      }
    }

    if team.shouldDelete == true {
      let itemsToDelete = try PersonalDataContentType.allCases.flatMap { type in
        switch type {
        case .credential:
          return try database.fetchAll(Credential.self, in: team)
        case .passkey:
          return try database.fetchAll(Passkey.self, in: team)

        case .secureNote:
          return try database.fetchAll(SecureNote.self, in: team)

        case .creditCard:
          return try database.fetchAll(CreditCard.self, in: team)
        case .bankAccount:
          return try database.fetchAll(BankAccount.self, in: team)

        case .email:
          return try database.fetchAll(Email.self, in: team)
        case .website:
          return try database.fetchAll(PersonalWebsite.self, in: team)
        case .address:
          return try database.fetchAll(Address.self, in: team)
        case .company:
          return try database.fetchAll(Company.self, in: team)
        case .phone:
          return try database.fetchAll(Phone.self, in: team)

        case .identity:
          return try database.fetchAll(Identity.self, in: team)
        case .idCard:
          return try database.fetchAll(IDCard.self, in: team)
        case .driverLicence:
          return try database.fetchAll(DrivingLicence.self, in: team)
        case .passport:
          return try database.fetchAll(Passport.self, in: team)

        case .socialSecurityInfo:
          return try database.fetchAll(Address.self, in: team)
        case .taxNumber:
          return try database.fetchAll(FiscalInformation.self, in: team)

        case .collection:
          return try database.fetchAll(PrivateCollection.self).filter(spaceId: team.personalDataId)
            .map { $0 as PersonalDataCodable }

        case .generatedPassword, .credentialCategory, .secureNoteCategory, .securityBreach,
          .settings, .dataChangeHistory, .secureFileInfo:
          return []
        case .secret:
          return try database.fetchAll(Secret.self, in: team)
        }
      }

      try database.delete(itemsToDelete)

      notifyDelete(for: team)
    }
  }
}

extension TeamSpaceRevokeHandler {
  private func notifyDelete(for team: CorePremium.Status.B2bStatus.PastTeamsElement) {
    Task {
      _ = try await apiClient.spaceDeleted(teamId: team.teamId)
    }
  }
}

extension ApplicationDatabase {
  func fetchAll<Output: VaultItem>(
    _ type: Output.Type,
    in team: CorePremium.Status.B2bStatus.PastTeamsElement
  ) throws -> [PersonalDataCodable] {
    try fetchAll(Output.self).filter {
      $0.spaceId == team.personalDataId || $0.isAssociated(to: team.teamInfo)
    }
  }
}
