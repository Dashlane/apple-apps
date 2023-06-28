import Foundation
import DashTypes
import CoreSync
import Combine
import CoreNetworking
import IconLibrary
import CoreCategorizer
import CoreUserTracking

public class ChooseWebsiteViewModel: ObservableObject, AuthenticatorServicesInjecting, AuthenticatorMockInjecting {

    @Published
    var searchCriteria = ""

    let placeholderWebsites = [
        "google.com",
        "facebook.com",
        "amazon.com",
        "paypal.com",
        "github.com"
    ]

    @Published
    var searchedWebsites: [String] = []

    let placeholderViewModelFactory: PlaceholderWebsiteViewModel.Factory

    private var cancellables = Set<AnyCancellable>()

    let completion: (String) -> Void
    let allDomains: [String]

    public init(categorizer: CategorizerProtocol,
                activityReporter: ActivityReporterProtocol,
                placeholderViewModelFactory: PlaceholderWebsiteViewModel.Factory,
                completion: @escaping (String) -> Void) {
        self.placeholderViewModelFactory = placeholderViewModelFactory
        self.completion = completion
        allDomains = (try? categorizer.getAllDomains()) ?? []
        self.setupSearch()
    }

    private func setupSearch() {
        $searchCriteria
            .throttle(for: .milliseconds(200), scheduler: DispatchQueue.global(), latest: true)
            .filter({ !$0.isEmpty })
            .map { [allDomains] searchCriteria in
                Array(allDomains
                    .filter { $0.starts(with: searchCriteria) }
                    .prefix(10))
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$searchedWebsites)
    }
}

extension ChooseWebsiteViewModel {
    public static func mock(includeSearchedWebsites: Bool = false,
                            completion: @escaping (String) -> Void = { _ in }) -> ChooseWebsiteViewModel {
        let model = AuthenticatorMockContainer().makeChooseWebsiteViewModel { _ in

        }
        if includeSearchedWebsites {
            model.searchCriteria = "search"
            model.searchedWebsites = ["netflix.com", "facebook.com"]
        }
        return model
    }
}
