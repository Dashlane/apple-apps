import CorePasswords
import CorePersonalData
import CorePremium
import Foundation
import SwiftTreats
import UIDelight
import UserTrackingFoundation

final class ExportSecureArchiveViewModel: ObservableObject, SessionServicesInjecting {

  let databaseDriver: DatabaseDriver
  let reporter: ActivityReporterProtocol
  let userSpacesService: UserSpacesService
  let onlyExportPersonalSpace: Bool

  @Published
  var inProgress = false

  @Published
  var passwordInput: String = "" {
    didSet {
      if passwordInput.isEmpty {
        passwordStrength = nil
      } else {
        passwordStrength = evaluator.evaluate(passwordInput)
      }
    }
  }

  @Published
  var displayInputError = false

  @Published
  var activityItem: ActivityItem?

  @Published
  var exportedArchiveURL: URL?

  @Published
  var showAlert = true

  @Published
  var passwordStrength: PasswordStrength?

  let evaluator: PasswordEvaluatorProtocol

  init(
    databaseDriver: DatabaseDriver,
    reporter: ActivityReporterProtocol,
    userSpacesService: UserSpacesService,
    onlyExportPersonalSpace: Bool = false,
    evaluator: PasswordEvaluatorProtocol
  ) {
    self.databaseDriver = databaseDriver
    self.reporter = reporter
    self.userSpacesService = userSpacesService
    self.onlyExportPersonalSpace = onlyExportPersonalSpace
    self.evaluator = evaluator
  }

  private var isPasswordValid: Bool {
    guard let passwordStrength else {
      return false
    }
    return passwordStrength >= PasswordStrength.somewhatGuessable
  }

  func export() {
    guard isPasswordValid else {
      return
    }
    inProgress = true

    Task.detached(priority: .utility) { [weak self] in
      guard let self = self else { return }

      let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(
        "Dashlane Secure Archive.dash")
      let exportURL = try self.databaseDriver.exportSecureArchive(
        usingPassword: self.passwordInput, to: fileURL,
        filter: { [weak self] record in
          onlyExportPersonalSpace
            ? self?.userSpacesService.configuration.virtualUserSpace(
              forPersonalDataSpaceId: record.content[.spaceId]) == .personal : true
        })

      await MainActor.run {
        if Device.is(.mac) {
          self.exportedArchiveURL = exportURL
        } else {
          self.activityItem = ActivityItem(items: exportURL)
        }
      }

      self.reporter.report(
        UserEvent.ExportData(
          backupFileType: .dash, exportDataStatus: .success, exportDataStep: .success,
          exportDestination: .sourceDash))
    }
  }

  static var mock: ExportSecureArchiveViewModel {
    return ExportSecureArchiveViewModel(
      databaseDriver: InMemoryDatabaseDriver(),
      reporter: .mock,
      userSpacesService: .mock(),
      evaluator: PasswordEvaluatorMock.mock())
  }
}
