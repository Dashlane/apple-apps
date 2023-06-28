import Combine
import DashlaneAppKit
import Foundation
import CorePersonalData
import CoreUserTracking
import VaultKit
import CorePremium

@MainActor
public class DashImportFlowViewModel: ImportFlowViewModel, ImportKitServicesInjecting {

    public typealias AnyImportViewModel = DashImportViewModel
    public var fileData: Data?
    public var isLoading: Bool = false

    public var importViewModel: DashImportViewModel!
    public let kind: ImportFlowKind = .dash

    @Published
    public var steps: [ImportFlowStep]

    @Published
    public var showPasswordView: Bool = false

    public var dismissPublisher: AnyPublisher<ImportDismissAction, Never> {
        return dismissSubject.eraseToAnyPublisher()
    }

    private let applicationDatabase: ApplicationDatabase
    private let databaseDriver: DatabaseDriver
    private let iconService: IconServiceProtocol
    private let activityReporter: ActivityReporterProtocol
    private let dashImportViewModelFactory: DashImportViewModel.Factory

    private let dismissSubject = PassthroughSubject<ImportDismissAction, Never>()

    public init(
        initialStep: ImportFlowStep?,
        applicationDatabase: ApplicationDatabase,
        databaseDriver: DatabaseDriver,
        iconService: IconServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        dashImportViewModelFactory: DashImportViewModel.Factory,
        importInformationViewModelFactory: ImportInformationViewModel.Factory
    ) {
        if let initialStep = initialStep {
            steps = [initialStep]
        } else {
            steps = []
        }
        self.applicationDatabase = applicationDatabase
        self.databaseDriver = databaseDriver
        self.iconService = iconService
        self.activityReporter = activityReporter
        self.dashImportViewModelFactory = dashImportViewModelFactory
    }

    public convenience init(
        shouldHaveInitialStep: Bool = true,
        applicationDatabase: ApplicationDatabase,
        databaseDriver: DatabaseDriver,
        iconService: IconServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        dashImportViewModelFactory: DashImportViewModel.Factory,
        importInformationViewModelFactory: ImportInformationViewModel.Factory
    ) {
        let step = ImportFlowStep.intro(importInformationViewModelFactory.make(kind: .dash, step: .intro))
        self.init(initialStep: shouldHaveInitialStep ? step : nil,
                  applicationDatabase: applicationDatabase,
                  databaseDriver: databaseDriver,
                  iconService: iconService,
                  activityReporter: activityReporter,
                  dashImportViewModelFactory: dashImportViewModelFactory,
                  importInformationViewModelFactory: importInformationViewModelFactory)
    }

    public func makeImportViewModel(withSecureArchiveData: Data) {
        let importService = DashImportService(secureArchiveData: withSecureArchiveData,
                                              applicationDatabase: applicationDatabase,
                                              databaseDriver: databaseDriver)
        let viewModel = dashImportViewModelFactory.make(importService: importService)
        self.importViewModel = viewModel
    }

    public func makeImportPasswordViewModel() -> DashImportViewModel {
        return importViewModel
    }

    public func handleIntroAction(_ action: ImportInformationView.Action) {
        switch action {
        case .importCompleted(let data):
            makeImportViewModel(withSecureArchiveData: data)
            showPasswordView = true
        case .close, .nextInfo, .done:
            assertionFailure("Inadmissible action for this step")
        }
    }

    public func handlePasswordAction(_ action: DashImportPasswordView.Action) {
        defer {
            showPasswordView = false
        }
        switch action {
        case .extracted:
            removeLastViewFromStackIfShouldBePopped()
            steps.append(.list(importViewModel))
        case .extractionError:
            removeLastViewFromStackIfShouldBePopped()
            steps.append(.error(importViewModel))
        case .cancel:
            break
        }
    }

    public func handleListAction(_ action: ImportListView<DashImportViewModel>.Action) {
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
            makeImportViewModel(withSecureArchiveData: data)
            showPasswordView = true
        }
    }

}

public extension DashImportFlowViewModel {
    static func mock(initialStep: ImportFlowStep? = nil, importInformation: ImportInformationViewModel = .dashMock) -> DashImportFlowViewModel {
        DashImportFlowViewModel(initialStep: initialStep ?? .intro(importInformation),
                                applicationDatabase: ApplicationDBStack.mock(),
                                databaseDriver: InMemoryDatabaseDriver(),
                                iconService: .mock(),
                                activityReporter: .fake,
                                dashImportViewModelFactory: .init({ _ in .mock }),
                                importInformationViewModelFactory: .init({ _, _ in importInformation }))
    }
}
