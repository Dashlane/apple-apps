import SwiftUI
import Combine
import DashlaneAppKit
import CoreUserTracking
import DashTypes

enum ImportMethodCompletion {
    case back
    case methodSelected(ImportMethod)
    case dwmScanPromptDismissed
    case dwmScanRequested
}

struct ImportMethodSection: Identifiable {
    let id: String
    let items: [ImportMethod]
    let header: String?

    init(section: (header: String?, methods: [ImportMethod])) {
        self.id = UUID().uuidString
        self.items = section.methods
        self.header = section.header?.localizedUppercase
    }
}

protocol ImportMethodViewModelProtocol: ObservableObject {
    var shouldShowDWMScanPrompt: Bool { get }
    var shouldShowDWMScanResult: Bool { get }
    var sections: [ImportMethodSection] { get }
    var completion: (ImportMethodCompletion) -> Void { get }

    func logDisplay()
    func dismissLastChanceScanPrompt()
    func startDWMScan()
    func methodSelected(_ method: ImportMethod)
    func back()
}

class ImportMethodViewModel: ImportMethodViewModelProtocol, SessionServicesInjecting {

    enum Action {
        case back
        case methodSelected(ImportMethod)
    }

    @Published
    var shouldShowDWMScanPrompt: Bool 

    @Published
    var shouldShowDWMScanResult: Bool 

    let sections: [ImportMethodSection]
    let completion: (ImportMethodCompletion) -> Void

    private let usageLogService: DWMLogService
    private let dwmOnboardingService: DWMOnboardingService
    private let dwmSettings: DWMOnboardingSettings
    private let activityReporter: ActivityReporterProtocol
    private let importService: ImportMethodServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(usageLogService: UsageLogServiceProtocol,
         dwmSettings: DWMOnboardingSettings,
         dwmOnboardingService: DWMOnboardingService,
         importService: ImportMethodServiceProtocol,
         activityReporter: ActivityReporterProtocol,
         completion: @escaping (ImportMethodCompletion) -> Void) {
        self.usageLogService = usageLogService.dwmLogService
        self.dwmSettings = dwmSettings
        self.dwmOnboardingService = dwmOnboardingService
        self.importService = importService
        self.activityReporter = activityReporter
        self.completion = completion

        sections = importService.methods

                shouldShowDWMScanPrompt = dwmOnboardingService.shouldShowLastChanceScanPrompt
        shouldShowDWMScanResult = dwmOnboardingService.shouldShowBreachesNotFoundInImportMethodsView
        setupSubscriptions()
    }

    func logDisplay() {
        if shouldShowDWMScanResult {
            usageLogService.log(.noBreachesFoundMessageDisplayed)
        }

        if shouldShowDWMScanPrompt {
            usageLogService.log(.lastChanceScanPromptDisplayed)
        }

        if case .firstPassword = importService.mode {
            activityReporter.reportPageShown(.homeAddItem)
        }
    }

    func back() {
        cancellables.forEach { $0.cancel() }
        completion(.back)
    }

    func methodSelected(_ method: ImportMethod) {
        completion(.methodSelected(method))
    }

        func dismissLastChanceScanPrompt() {
        usageLogService.log(.lastChanceScanPromptDismissed)
        completion(.dwmScanPromptDismissed)
    }

    func startDWMScan() {
        usageLogService.log(.lastChanceScanPromptAccepted)
        completion(.dwmScanRequested)
    }

    private func setupSubscriptions() {
                let dismissedPublisher: AnyPublisher<Bool?, Never> = dwmSettings.changeMonitoringPublisher(key: .hasDismissedLastChanceScanPrompt)
        dismissedPublisher.removeDuplicates().receive(on: DispatchQueue.main).sink { [weak self] dismissed in
            if dismissed == true {
                self?.shouldShowDWMScanPrompt = false
            }
        }.store(in: &cancellables)

                dwmOnboardingService.progressPublisher().removeDuplicates().receive(on: DispatchQueue.main).sink { [weak self] progress in
            guard let progress = progress else {
                return
            }

            if progress >= .emailRegistrationRequestSent {
                self?.shouldShowDWMScanPrompt = false
            }
        }.store(in: &cancellables)
    }
}
