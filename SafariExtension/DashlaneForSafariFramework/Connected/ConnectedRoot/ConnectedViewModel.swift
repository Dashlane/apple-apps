import Foundation
import CoreSession
import Combine
import CoreUserTracking

class ConnectedViewModel: ObservableObject {
    
    @Published var allTabs: [MainTab] = []
    
    @Published
    var selectedTab: MainTab
    
    let appServices: SafariExtensionAppServices
    let sessionServicesContainer: SessionServicesContainer
    
    private let vaultTab: MainTab
    private let autofillTab: MainTab
    private let passwordGeneratorTab: MainTab
    private let other: MainTab
    
    var cancellables = Set<AnyCancellable>()
    
    init(session: Session,
         appServices: SafariExtensionAppServices,
         sessionServicesContainer: SessionServicesContainer) {
        self.appServices = appServices
        self.sessionServicesContainer = sessionServicesContainer
        
        let vaultViewModel = VaultViewModel(sessionServicesContainer: sessionServicesContainer)
        let passwordGeneratorTabViewModel = sessionServicesContainer.viewModelFactory.makePasswordGeneratorTabViewModel()
        
        passwordGeneratorTab = MainTab.passwordGenerator(passwordGeneratorTabViewModel)
        vaultTab = MainTab.vault(vaultViewModel)
        let autofillModel = sessionServicesContainer.viewModelFactory.makeAutofillTabViewModel()
        autofillTab = MainTab.autofill(autofillModel)
        let otherViewModel = sessionServicesContainer.viewModelFactory.makeMoreTabViewModel(login: sessionServicesContainer.session.login.email)
        other =  MainTab.other(otherViewModel)
       
        self.selectedTab = vaultTab
        self.refreshTabs()
        
        allTabs.forEach {
            $0.activable?.isActive
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    self.refreshTabs()
                }.store(in: &cancellables)
        }
        appServices.popoverOpeningService.publisher.sink { [weak self] opening in
            guard let self = self else { return }
            if opening == .afterTimeLimit {
                self.selectedTab = self.vaultTab
            }
            self.sessionServicesContainer.syncService.sync(triggeredBy: Definition.Trigger.periodic)
        }.store(in: &cancellables)
        
        appServices.autofillService.connect(sessionServices: sessionServicesContainer)
        
                appServices.communicationService.lastMessage
            .throttle(for: .seconds(5), scheduler: DispatchQueue.main, latest: false)
            .sink { message in
                guard message == .sync else { return }
                sessionServicesContainer.syncService.sync(triggeredBy: .wake)
            }
            .store(in: &cancellables)
    }
    
    private func refreshTabs() {
        self.allTabs = [
            vaultTab,
            autofillTab,
            passwordGeneratorTab,
            other
        ]
        if !selectedTab.isActive {
            self.selectedTab = vaultTab
        }
    }
}
