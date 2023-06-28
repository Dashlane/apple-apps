import Foundation
import CoreUserTracking
import UniformTypeIdentifiers

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

    public init(kind: ImportFlowKind, step: ImportInformationViewModel.Step, activityReporter: ActivityReporterProtocol) {
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
        activityReporter.report(UserEvent.ImportData(backupFileType: kind.backupFileType,
                                                     importDataStatus: .start,
                                                     importDataStep: .selectFile,
                                                     importSource: kind.importSource,
                                                     isDirectImport: false))
    }
}

public extension ImportInformationViewModel {
    static var dashMock: ImportInformationViewModel {
        return .init(kind: .dash, step: .intro, activityReporter: .fake)
    }

    static var keychainIntroMock: ImportInformationViewModel {
        return .init(kind: .keychain, step: .intro, activityReporter: .fake)
    }

    static var keychainInstructionsMock: ImportInformationViewModel {
        return .init(kind: .keychain, step: .instructions, activityReporter: .fake)
    }

    static var chromeIntroMock: ImportInformationViewModel {
        return .init(kind: .chrome, step: .intro, activityReporter: .fake)
    }

    static var chromeInstrutionsMock: ImportInformationViewModel {
        return .init(kind: .chrome, step: .instructions, activityReporter: .fake)
    }

    static var chromeExtensionMock: ImportInformationViewModel {
        return .init(kind: .chrome, step: .extension, activityReporter: .fake)
    }
}
