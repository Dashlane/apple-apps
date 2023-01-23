import Combine
import DashlaneAppKit
import Foundation
import CorePersonalData
import CoreUserTracking
import VaultKit

public class DashImportFlowViewModel: ImportFlowViewModel {

    public typealias AnyImportViewModel = DashImportViewModel

    public var importViewModel: DashImportViewModel!
    public let kind: ImportFlowKind = .dash

    @Published
    public var steps: [ImportFlowStep]

    @Published
    public var showPasswordView: Bool = false

    public let shouldDisplayRootBackButton: Bool

    public var dismissPublisher: AnyPublisher<ImportDismissAction, Never> {
        return dismissSubject.eraseToAnyPublisher()
    }

    private let personalDataURLDecoder: CorePersonalData.PersonalDataURLDecoder
    private let applicationDatabase: ApplicationDatabase
    private let databaseDriver: DatabaseDriver
    private let iconService: IconServiceProtocol
    private let activityReporter: ActivityReporterProtocol

    private let dismissSubject = PassthroughSubject<ImportDismissAction, Never>()

    public init(
        initialStep: ImportFlowStep? = .intro(.init(kind: .dash, step: .intro)),
        fromDeeplink: Bool = false,
        personalDataURLDecoder: CorePersonalData.PersonalDataURLDecoder,
        applicationDatabase: ApplicationDatabase,
        databaseDriver: DatabaseDriver,
        iconService: IconServiceProtocol,
        activityReporter: ActivityReporterProtocol
    ) {
        steps = initialStep.map { [$0] } ?? []
        self.shouldDisplayRootBackButton = fromDeeplink
        self.personalDataURLDecoder = personalDataURLDecoder
        self.applicationDatabase = applicationDatabase
        self.databaseDriver = databaseDriver
        self.iconService = iconService
        self.activityReporter = activityReporter
    }

    public func makeImportViewModel(withSecureArchiveData: Data) {
        let importService = DashImportService(secureArchiveData: withSecureArchiveData,
                                              applicationDatabase: applicationDatabase,
                                              databaseDriver: databaseDriver)
        let viewModel = DashImportViewModel(importService: importService,
                                            iconService: iconService,
                                            personalDataURLDecoder: personalDataURLDecoder,
                                            activityReporter: activityReporter)
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
