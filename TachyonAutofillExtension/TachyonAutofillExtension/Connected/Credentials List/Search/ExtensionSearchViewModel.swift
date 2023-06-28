import Foundation
import CorePersonalData
import Combine
import CoreFeature
import DashlaneAppKit
import IconLibrary
import VaultKit

protocol ExtensionSearchViewModelProtocol: ObservableObject {
    var searchCriteria: String { get set }
    var isActive: Bool { get set }
    var result: SearchResult { get }
    var recentSearchItems: [DataSection] { get set }
    var domainIconLibrary: DomainIconLibrary { get }
}

class ExtensionSearchViewModel: ExtensionSearchViewModelProtocol {
    @Published
    var result: SearchResult = SearchResult(searchCriteria: "", sections: [])

    @Published
    var searchCriteria: String
    
    @Published
    var isActive: Bool
    
    @Published
    var recentSearchItems: [DataSection] = []
    
    let domainIconLibrary: DomainIconLibrary
    private let queue = DispatchQueue(label: "extensionSearch", qos: .userInteractive)
    private var cancellables = Set<AnyCancellable>()
    private let credentialsListService: CredentialListService
    
    init(credentialsListService: CredentialListService,
         domainIconLibrary: DomainIconLibrary) {
        self.credentialsListService = credentialsListService
        self.searchCriteria = ""
        self.isActive = false
        self.domainIconLibrary = domainIconLibrary
        setup()
    }
    
    func setup() {
        let searchPublisher =  $searchCriteria
            .debounce(for: .milliseconds(300), scheduler: queue)

        credentialsListService
            .$allCredentials
            .combineLatest(searchPublisher) { credentials, criteria in
                guard !criteria.isEmpty else {
                    return SearchResult(searchCriteria: criteria, sections: [])
                }
                                
                let filteredCredentials = credentials
                    .filterAndSortItemsUsingCriteria(criteria)
                    
                let section = DataSection.init(items: filteredCredentials)
                return SearchResult(searchCriteria: criteria, sections: [section])
            }
        .receive(on: RunLoop.main)
        .assign(to: \.result, on: self)
            .store(in: &cancellables)
        
        credentialsListService
            .$allCredentials
            .map { credentials -> [DataSection] in
                let recentSearchedItems = credentials
                    .filter { $0.metadata.lastLocalSearchDate != nil }
                    .sorted { left, right in
                        guard let leftDate = left.metadata.lastLocalSearchDate,
                              let rightDate = right.metadata.lastLocalSearchDate else { return false }
                        return leftDate > rightDate
                    }
                return [DataSection(name: L10n.Localizable.recentSearchTitle, items: recentSearchedItems)]
            }
            .receive(on: RunLoop.main)
            .assign(to: \.recentSearchItems, on: self)
            .store(in: &cancellables)
    }
}
