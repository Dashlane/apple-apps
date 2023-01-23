import Combine
import Foundation
import CoreSettings

public class ChromeImportFlowViewModel: ImportFlowViewModel {

    public typealias AnyImportViewModel = ChromeImportViewModel

    public let kind: ImportFlowKind = .chrome

    @Published
    public var steps: [ImportFlowStep]

    public var showPasswordView: Bool = false
    public let shouldDisplayRootBackButton: Bool

    public var dismissPublisher: AnyPublisher<ImportDismissAction, Never> {
        return dismissSubject.eraseToAnyPublisher()
    }

    private let userSettings: UserSettings

    private let dismissSubject = PassthroughSubject<ImportDismissAction, Never>()

    private var importViewModel: ChromeImportViewModel!

    public init(initialStep: ImportFlowStep = .intro(.init(kind: .chrome, step: .intro)),
                fromDeeplink: Bool = false,
                userSettings: UserSettings) {
        self.steps = [initialStep]
        self.shouldDisplayRootBackButton = fromDeeplink
        self.userSettings = userSettings
    }

    public func handleIntroAction(_ action: ImportInformationView.Action) {
        switch action {
        case .nextInfo:
            steps.append(.instructions(.init(kind: kind, step: .instructions)))
        case .close, .importCompleted, .done:
            assertionFailure("Inadmissible action for this step")
        }
    }

    public func handleInstructionsAction(_ action: ImportInformationView.Action) {
        switch action {
        case .nextInfo:
            steps.append(.extension(.init(kind: kind, step: .extension)))
        case .close, .importCompleted, .done:
            assertionFailure("Inadmissible action for this step")
        }
    }

    public func handleExtensionAction(_ action: ImportInformationView.Action) {
        switch action {
        case .nextInfo:
            steps.append(.instructions(.init(kind: kind, step: .instructions)))
        case .close, .importCompleted:
            assertionFailure("Inadmissible action for this step")
        case .done:
            userSettings[.chromeImportDidFinishOnce] = true
                                    userSettings[.m2wDidFinishOnce] = true
            dismissSubject.send(.dismiss)
        }
    }

}
