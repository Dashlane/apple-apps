import Combine
import DashlaneAppKit
import Foundation
import CorePersonalData
import CoreUserTracking
import VaultKit

public class KeychainImportFlowViewModel: ImportFlowViewModel {

    public typealias AnyImportViewModel = KeychainImportViewModel

    public let kind: ImportFlowKind = .keychain

    @Published
    public var steps: [ImportFlowStep]

    public var showPasswordView: Bool = false
    public let shouldDisplayRootBackButton: Bool

    public var dismissPublisher: AnyPublisher<ImportDismissAction, Never> {
        return dismissSubject.eraseToAnyPublisher()
    }

    private let personalDataURLDecoder: CorePersonalData.PersonalDataURLDecoder
    private let applicationDatabase: ApplicationDatabase
    private let iconService: IconServiceProtocol
    private let activityReporter: ActivityReporterProtocol

    private let dismissSubject = PassthroughSubject<ImportDismissAction, Never>()

    private var importViewModel: KeychainImportViewModel!

    public init(
        initialStep: ImportFlowStep = .intro(.init(kind: .keychain, step: .intro)),
        fromDeeplink: Bool = false,
        personalDataURLDecoder: CorePersonalData.PersonalDataURLDecoder,
        applicationDatabase: ApplicationDatabase,
        iconService: IconServiceProtocol,
        activityReporter: ActivityReporterProtocol
    ) {
        steps = [initialStep]
        self.shouldDisplayRootBackButton = fromDeeplink
        self.personalDataURLDecoder = personalDataURLDecoder
        self.applicationDatabase = applicationDatabase
        self.iconService = iconService
        self.activityReporter = activityReporter
    }

    private func makeImportViewModel(withArchiveData: Data) {
        let importService = KeychainImportService(file: withArchiveData,
                                                  applicationDatabase: applicationDatabase)
        let viewModel = KeychainImportViewModel(importService: importService,
                                                iconService: iconService,
                                                personalDataURLDecoder: personalDataURLDecoder,
                                                activityReporter: activityReporter)
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
            steps.append(.instructions(.init(kind: kind, step: .instructions)))
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

    public func handleListAction(_ action: ImportListView<KeychainImportViewModel>.Action) {
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
