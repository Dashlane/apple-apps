import Combine
import Foundation
import CoreSettings

@MainActor
public class ChromeImportFlowViewModel: ImportFlowViewModel, ImportKitServicesInjecting {
    public var fileData: Data?
    public var isLoading: Bool = false

    public typealias AnyImportViewModel = ChromeImportViewModel

    public let kind: ImportFlowKind = .chrome

    @Published
    public var steps: [ImportFlowStep]

    public var showPasswordView: Bool = false

    public var dismissPublisher: AnyPublisher<ImportDismissAction, Never> {
        return dismissSubject.eraseToAnyPublisher()
    }

    private let userSettings: UserSettings

    private let dismissSubject = PassthroughSubject<ImportDismissAction, Never>()

    private var importViewModel: ChromeImportViewModel!

    let importInformationViewModelFactory: ImportInformationViewModel.Factory

    public init(initialStep: ImportFlowStep,
                userSettings: UserSettings,
                importInformationViewModelFactory: ImportInformationViewModel.Factory) {
        self.steps = [initialStep]
        self.userSettings = userSettings
        self.importInformationViewModelFactory = importInformationViewModelFactory
    }

    public convenience init(userSettings: UserSettings,
                            importInformationViewModelFactory: ImportInformationViewModel.Factory) {
        let step = ImportFlowStep.intro(importInformationViewModelFactory.make(kind: .chrome, step: .intro))
        self.init(initialStep: step,
                  userSettings: userSettings,
                  importInformationViewModelFactory: importInformationViewModelFactory)
    }

    public func handleIntroAction(_ action: ImportInformationView.Action) {
        switch action {
        case .nextInfo:
            let viewModel = importInformationViewModelFactory.make(kind: kind, step: .instructions)
            steps.append(.instructions(viewModel))
        case .close, .importCompleted, .done:
            assertionFailure("Inadmissible action for this step")
        }
    }

    public func handleInstructionsAction(_ action: ImportInformationView.Action) {
        switch action {
        case .nextInfo:
            let viewModel = importInformationViewModelFactory.make(kind: kind, step: .extension)
            steps.append(.extension(viewModel))
        case .close, .importCompleted, .done:
            assertionFailure("Inadmissible action for this step")
        }
    }

    public func handleExtensionAction(_ action: ImportInformationView.Action) {
        switch action {
        case .nextInfo:
            let viewModel = importInformationViewModelFactory.make(kind: kind, step: .instructions)
            steps.append(.instructions(viewModel))
        case .close, .importCompleted:
            assertionFailure("Inadmissible action for this step")
        case .done:
            userSettings[.chromeImportDidFinishOnce] = true
                                    userSettings[.m2wDidFinishOnce] = true
            dismissSubject.send(.dismiss)
        }
    }

}
