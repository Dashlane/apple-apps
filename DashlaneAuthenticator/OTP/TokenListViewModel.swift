import Foundation
import Combine
import CorePersonalData
import DashlaneAppKit
import TOTPGenerator
import IconLibrary
import DashTypes
import AuthenticatorKit

class TokenListViewModel: ObservableObject {
    @Published
    var tokens = [OTPInfo]()
    
    @Published
    var favorites = [OTPInfo]()
    
    @Published
    var popoverItem: OTPInfo? = nil

    var cancellables = Set<AnyCancellable>()
    
    let databaseService: AuthenticatorDatabaseServiceProtocol
    let didDelete: (OTPInfo) -> Void
    let tokenRowViewModelFactory: TokenRowViewModel.Factory
    
    @Published
    var steps: [Step] = []
    
    enum Step: Identifiable {
        case list
        case detail(OTPInfo)
        case help
        
        var id: String {
            switch self {
            case .list:
                return "list"
            case .help:
                return "help"
            case let .detail(item):
                return item.id.rawValue
            }
        }
    }
    
    init(databaseService: AuthenticatorDatabaseServiceProtocol,
         tokenRowViewModelFactory: TokenRowViewModel.Factory,
         didDelete: @escaping (OTPInfo) -> Void) {
        self.databaseService = databaseService
        self.tokenRowViewModelFactory = tokenRowViewModelFactory
        self.didDelete = didDelete
        databaseService.codesPublisher
            .map({ $0.sortedByIssuer() })
            .map { $0.seprateByIsFavorite() }
            .sink(receiveValue: { codes in
                self.tokens = codes[false] ?? []
                self.favorites = codes[true] ?? []
            })
            .store(in: &cancellables)
        steps.append(.list)
    }

    func makeTokenRowViewModel(for token: OTPInfo) -> TokenRowViewModel {
        return tokenRowViewModelFactory.make(token: token, dashlaneTokenCaption: L10n.Localizable.dashlanePairedTitle)
    }
    
    func delete(item: OTPInfo) {
        do {
            try databaseService.delete(item)
            self.didDelete(item)
        } catch {
                        assertionFailure()
        }
    }
    
    func update(item: OTPInfo) {
        do {
            try databaseService.update(item)
        } catch {
                        assertionFailure()
        }
    }
    
    func showHelp() {
        steps.append(.help)
    }
}

extension [OTPInfo] {
    func seprateByIsFavorite() -> [Bool: [OTPInfo]] {
        self.reduce(into: [Bool: [OTPInfo]]()) { partialResult, otpInfo in
            partialResult[otpInfo.isFavorite, default: []].append(otpInfo)
        }
    }
}
