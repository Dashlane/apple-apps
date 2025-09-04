public enum ExportVaultStatus {
  case limited
  case disabled
  case complete
}

extension Status {
  public var exportStatus: ExportVaultStatus {
    guard let team = b2bStatus?.currentTeam else {
      return .complete
    }

    if team.teamInfo.personalSpaceEnabled == false {
      return team.teamInfo.vaultExportEnabled == true ? .complete : .disabled
    } else if team.teamInfo.forcedDomainsEnabled == true {
      return .limited
    } else {
      return .complete
    }
  }
}
