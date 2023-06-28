import Combine
import DashlaneAppKit
import Foundation
import CorePersonalData
import CoreUserTracking
import VaultKit
import CorePremium

@MainActor
public class KeychainImportFlowViewModel: ImportFlowViewModel, ImportKitServicesInjecting {

    public typealias AnyImportViewModel = CSVImportViewModel
    public var fileData: Data?
    public var isLoading: Bool = false

    public let kind: ImportFlowKind = .keychain

    @Published
    public var steps: [ImportFlowStep]

    public var showPasswordView: Bool = false

    public var dismissPublisher: AnyPublisher<ImportDismissAction, Never> {
        return dismissSubject.eraseToAnyPublisher()
    }

    private let personalDataURLDecoder: PersonalDataURLDecoderProtocol
    private let applicationDatabase: ApplicationDatabase
    private let iconService: IconServiceProtocol
    private let activityReporter: ActivityReporterProtocol

    private let dismissSubject = PassthroughSubject<ImportDismissAction, Never>()

    private var importViewModel: CSVImportViewModel!
    private let csvImportViewModelFactory: CSVImportViewModel.Factory
    private let importInformationViewModelFactory: ImportInformationViewModel.Factory

    public init(
        initialStep: ImportFlowStep,
        personalDataURLDecoder: PersonalDataURLDecoderProtocol,
        applicationDatabase: ApplicationDatabase,
        iconService: IconServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        csvImportViewModelFactory: CSVImportViewModel.Factory,
        importInformationViewModelFactory: ImportInformationViewModel.Factory
    ) {
        steps = [initialStep]
        self.personalDataURLDecoder = personalDataURLDecoder
        self.applicationDatabase = applicationDatabase
        self.iconService = iconService
        self.activityReporter = activityReporter
        self.csvImportViewModelFactory = csvImportViewModelFactory
        self.importInformationViewModelFactory = importInformationViewModelFactory
    }

    public convenience init(
        personalDataURLDecoder: PersonalDataURLDecoderProtocol,
        applicationDatabase: ApplicationDatabase,
        iconService: IconServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        csvImportViewModelFactory: CSVImportViewModel.Factory,
        importInformationViewModelFactory: ImportInformationViewModel.Factory
    ) {
        let step = ImportFlowStep.intro(importInformationViewModelFactory.make(kind: .keychain, step: .intro))
        self.init(initialStep: step,
                  personalDataURLDecoder: personalDataURLDecoder,
                  applicationDatabase: applicationDatabase,
                  iconService: iconService,
                  activityReporter: activityReporter,
                  csvImportViewModelFactory: csvImportViewModelFactory,
                  importInformationViewModelFactory: importInformationViewModelFactory)
    }

    private func makeImportViewModel(withArchiveData: Data) {
        let importService = CSVImportService(file: withArchiveData,
                                             csvOrigin: .keychain,
                                             applicationDatabase: applicationDatabase,
                                             personalDataURLDecoder: personalDataURLDecoder)
        let viewModel = csvImportViewModelFactory.make(importService: importService,
                                                       didSave: {
            self.dismissSubject.send(.dismiss)
        })
        self.importViewModel = viewModel
    }

    public func makeImportPasswordViewModel() -> DashImportViewModel {
        fatalError("Inadmissible action for this kind of import flow")
    }

    public func handleIntroAction(_ action: ImportInformationView.Action) {
        switch action {
        case .importCompleted(let data):
            handleImportCompleted(data)
        case .nextInfo, .done:
            let viewModel = importInformationViewModelFactory.make(kind: kind, step: .instructions)
            steps.append(.instructions(viewModel))
        case .close:
            assertionFailure("Inadmissible action for this step")
        }
    }

    public func handleInstructionsAction(_ action: ImportInformationView.Action) {
        switch action {
        case .importCompleted(let data):
            handleImportCompleted(data)
        case .nextInfo, .done:
            assertionFailure("Inadmissible action for this step")
        case .close:
            dismissSubject.send(.popToRootView)
        }
    }

    func handleImportCompleted(_ data: Data) {
        makeImportViewModel(withArchiveData: data)

        Task {
            do {
                try await importViewModel.extract()
                removeLastViewFromStackIfShouldBePopped()
                steps.append(.list(importViewModel))
            } catch {
                removeLastViewFromStackIfShouldBePopped()
                steps.append(.error(importViewModel))
            }
        }
    }

    public func handleListAction(_ action: ImportListView<CSVImportViewModel>.Action) {
        switch action {
        case .saved:
            dismissSubject.send(.dismiss)
        case .savingError:
            removeLastViewFromStackIfShouldBePopped()
            steps.append(.error(importViewModel))
        }
    }

    public func handleErrorAction(_ action: ImportErrorView.Action) {
        switch action {
        case .saved:
            dismissSubject.send(.dismiss)
        case .importCompleted(let data):
            handleImportCompleted(data)
        }
    }

}
