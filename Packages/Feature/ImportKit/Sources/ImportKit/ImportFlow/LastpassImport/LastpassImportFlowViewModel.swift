import Combine
import DashlaneAppKit
import Foundation
import CorePersonalData
import CoreUserTracking
import VaultKit
import CoreSettings

@MainActor
public class LastpassImportFlowViewModel: ImportFlowViewModel, ImportKitServicesInjecting {

    public typealias AnyImportViewModel = CSVImportViewModel

    public let kind: ImportFlowKind = .lastpass

    @Published
    public var steps: [ImportFlowStep]

    @Published
    public var fileData: Data?

    @Published public var isLoading: Bool = false

    public var showPasswordView: Bool = false
    public let isDroppingFileEnabled: Bool = true

    public var dismissPublisher: AnyPublisher<ImportDismissAction, Never> {
        return dismissSubject.eraseToAnyPublisher()
    }

    private let personalDataURLDecoder: PersonalDataURLDecoderProtocol
    private let applicationDatabase: ApplicationDatabase
    private let iconService: IconServiceProtocol
    private let activityReporter: ActivityReporterProtocol
    private let userSettings: UserSettings
    private var subcriptions = Set<AnyCancellable>()

    private let dismissSubject = PassthroughSubject<ImportDismissAction, Never>()

    private var importViewModel: CSVImportViewModel!
    private let csvImportViewModelFactory: CSVImportViewModel.Factory

    public init(
        initialStep: ImportFlowStep,
        personalDataURLDecoder: PersonalDataURLDecoderProtocol,
        applicationDatabase: ApplicationDatabase,
        userSettings: UserSettings,
        iconService: IconServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        csvImportViewModelFactory: CSVImportViewModel.Factory,
        importInformationViewModelFactory: ImportInformationViewModel.Factory
    ) {
        steps = [initialStep]
        self.userSettings = userSettings
        self.personalDataURLDecoder = personalDataURLDecoder
        self.applicationDatabase = applicationDatabase
        self.iconService = iconService
        self.activityReporter = activityReporter
        self.csvImportViewModelFactory = csvImportViewModelFactory

        $fileData
            .compactMap { $0 }
            .sink { [weak self] fileData in
                self?.handleImportCompleted(fileData)
            }
            .store(in: &subcriptions)
    }

    public convenience init(
        personalDataURLDecoder: PersonalDataURLDecoderProtocol,
        applicationDatabase: ApplicationDatabase,
        userSettings: UserSettings,
        iconService: IconServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        csvImportViewModelFactory: CSVImportViewModel.Factory,
        importInformationViewModelFactory: ImportInformationViewModel.Factory
    ) {
        let step = ImportFlowStep.intro(importInformationViewModelFactory.make(kind: .lastpass, step: .intro))
        self.init(initialStep: step,
                  personalDataURLDecoder: personalDataURLDecoder,
                  applicationDatabase: applicationDatabase,
                  userSettings: userSettings,
                  iconService: iconService,
                  activityReporter: activityReporter,
                  csvImportViewModelFactory: csvImportViewModelFactory,
                  importInformationViewModelFactory: importInformationViewModelFactory)
    }

    private func makeImportViewModel(withArchiveData: Data) {
        let importService = CSVImportService(file: withArchiveData,
                                             csvOrigin: .lastpass,
                                             applicationDatabase: applicationDatabase,
                                             personalDataURLDecoder: personalDataURLDecoder)
        let viewModel = csvImportViewModelFactory.make(importService: importService) {
            self.userSettings[.lastpassImportPopupHasBeenShown] = true
            self.dismissSubject.send(.dismiss)
        }
        self.importViewModel = viewModel
    }

    public func makeImportPasswordViewModel() -> DashImportViewModel {
        fatalError("Inadmissible action for this kind of import flow")
    }

    public func handleIntroAction(_ action: ImportInformationView.Action) {
        switch action {
        case .importCompleted(let data):
            handleImportCompleted(data)
        case .close, .nextInfo, .done:
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

        isLoading = true
        Task {
            do {
                try await importViewModel.extract()
                self.isLoading = false
                removeLastViewFromStackIfShouldBePopped()
                steps.append(.list(importViewModel))
            } catch {
                self.isLoading = false
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
