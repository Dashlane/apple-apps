import Foundation
import CoreUserTracking
import UniformTypeIdentifiers

public class ImportInformationViewModel: ObservableObject {

    public enum Step {
        case intro
        case instructions
        case `extension`
    }

    let kind: ImportFlowKind
    let step: Step
    let pageToReport: Page

    public init(kind: ImportFlowKind, step: Step) {
        self.kind = kind
        self.step = step
        switch kind {
        case .chrome:
            self.pageToReport = .importChrome
        case .dash:
            self.pageToReport = .importBackupfile
        case .keychain:
            self.pageToReport = .importCsv
        }
    }

}

extension ImportInformationViewModel {
    static var dashMock: ImportInformationViewModel {
        return .init(kind: .dash, step: .intro)
    }

    static var keychainIntroMock: ImportInformationViewModel {
        return .init(kind: .keychain, step: .intro)
    }

    static var keychainInstructionsMock: ImportInformationViewModel {
        return .init(kind: .keychain, step: .instructions)
    }

    static var chromeIntroMock: ImportInformationViewModel {
        return .init(kind: .chrome, step: .intro)
    }

    static var chromeInstructionsMock: ImportInformationViewModel {
        return .init(kind: .chrome, step: .instructions)
    }

    static var chromeExtensionMock: ImportInformationViewModel {
        return .init(kind: .chrome, step: .extension)
    }
}
