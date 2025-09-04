import Foundation
import UniformTypeIdentifiers
import UserTrackingFoundation

public class ImportInformationViewModel: ObservableObject, ImportKitServicesInjecting {

  public enum Step {
    case intro
    case instructions
    case `extension`
  }

  let kind: ImportFlowKind
  let step: Step
  let pageToReport: Page
  let activityReporter: ActivityReporterProtocol

  public init(
    kind: ImportFlowKind, step: ImportInformationViewModel.Step,
    activityReporter: ActivityReporterProtocol
  ) {
    self.kind = kind
    self.step = step
    self.activityReporter = activityReporter
    switch kind {
    case .chrome:
      self.pageToReport = .importChrome
    case .dash:
      self.pageToReport = .importBackupfile
    case .keychain, .lastpass:
      self.pageToReport = .importCsv
    }
  }

  func reportImportStarted() {
    let kind = kind
    activityReporter.report(
      UserEvent.ImportData(
        backupFileType: kind.backupFileType,
        importDataStatus: .start,
        importDataStep: .selectFile,
        importSource: kind.importSource,
        isDirectImport: false))
  }
}

extension ImportInformationViewModel {
  public static var dashMock: ImportInformationViewModel {
    return .init(kind: .dash, step: .intro, activityReporter: .mock)
  }

  public static var keychainIntroMock: ImportInformationViewModel {
    return .init(kind: .keychain, step: .intro, activityReporter: .mock)
  }

  public static var keychainInstructionsMock: ImportInformationViewModel {
    return .init(kind: .keychain, step: .instructions, activityReporter: .mock)
  }

  public static var chromeIntroMock: ImportInformationViewModel {
    return .init(kind: .chrome, step: .intro, activityReporter: .mock)
  }

  public static var chromeInstrutionsMock: ImportInformationViewModel {
    return .init(kind: .chrome, step: .instructions, activityReporter: .mock)
  }

  public static var chromeExtensionMock: ImportInformationViewModel {
    return .init(kind: .chrome, step: .extension, activityReporter: .mock)
  }
}
