import Foundation
import Combine
import CorePasswords
import SwiftUI
import DashlaneAppKit
import CoreSettings
import DashTypes
import CorePersonalData
import CoreUserTracking
import VaultKit

class PasswordGeneratorTabViewModel: TabActivable, SessionServicesInjecting {
    let passwordGeneratorViewModel: PasswordGeneratorViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var isActive: CurrentValueSubject<Bool, Never> = .init(true)

    var pasteboardService: PasteboardService

    let database: ApplicationDatabase
    let userSettings: UserSettings
    let activityReporter: ActivityReporterProtocol
    let iconService: IconServiceProtocol
    
    init(passwordGeneratorViewModelFactory: PasswordGeneratorViewModel.SecondFactory,
         database: ApplicationDatabase,
         userSettings: UserSettings,
         activityReporter: ActivityReporterProtocol,
         iconService: IconServiceProtocol,
         popoverOpeningService: PopoverOpeningService,
         pasteboardService: PasteboardService) {
        let mode = PasswordGeneratorMode.standalone({ _ in })
        self.database = database
        self.userSettings = userSettings
        self.activityReporter = activityReporter
        self.iconService = iconService
        self.pasteboardService = pasteboardService
        self.passwordGeneratorViewModel = passwordGeneratorViewModelFactory.make(mode: mode, savePreferencesOnChange: false, copyAction: { password in
            pasteboardService.set(password)
        })
        popoverOpeningService.publisher.sink { [weak self] opening in
            guard let self = self else { return }
            if opening == .afterTimeLimit {
                self.passwordGeneratorViewModel.refreshPreferences()
            }
        }.store(in: &cancellables)
    }

    func makeHistoryViewModel() -> PasswordGeneratorHistoryViewModel {
        PasswordGeneratorHistoryViewModel(database: database,
                                         userSettings: userSettings,
                                         activityReporter: activityReporter,
                                         iconService: iconService)

    }
}

extension PasswordGeneratorViewModel: SessionServicesInjecting { }

extension PasswordGeneratorTabViewModel {
    static func mock() -> PasswordGeneratorTabViewModel {
        return PasswordGeneratorTabViewModel(passwordGeneratorViewModelFactory: .init(makeViewModel),
                                             database: ApplicationDBStack.mock(),
                                             userSettings: .mock,
                                             activityReporter: .fake,
                                             iconService: IconServiceMock(),
                                             popoverOpeningService: .init(),
                                             pasteboardService: PasteboardService.mock())
    }
    
    private static func makeViewModel(_ mode: PasswordGeneratorMode, _ savePreferencesOnChange: Bool, copyAction: @escaping ((String) -> Void)) -> PasswordGeneratorViewModel {
        let container = MockServicesContainer()
        return PasswordGeneratorViewModel(mode: mode,
                                          database: container.database,
                                          passwordEvaluator: .mock(),
                                          sessionActivityReporter: .fake,
                                          userSettings: UserSettings(internalStore: .mock()),
                                          copyAction: copyAction)
    }
}
