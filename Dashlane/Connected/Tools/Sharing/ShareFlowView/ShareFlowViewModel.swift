import Foundation
import VaultKit
import DashTypes
import CorePremium
import CoreSharing
import SwiftUI
import CoreLocalization

@MainActor
class ShareFlowViewModel: ObservableObject, SessionServicesInjecting, MockVaultConnectedInjecting {
    enum ComposeStep: Hashable {
        case items
        case recipients
    }

    enum State: Hashable {
        case composing
        case sending
        case success
    }

    @Published
    var composeSteps: [ComposeStep]

    @Published
    var state: State = .composing

    @Published
    var errorMessage: String = "" {
        didSet {
            showError = !errorMessage.isEmpty
        }
    }

    @Published
    var showError: Bool = false

    var items: [VaultItem] = []
    var recipientsConfiguration: RecipientsConfiguration = .init()

    let itemsViewModelFactory: ShareItemsSelectionViewModel.Factory
    let recipientsViewModelFactory: ShareRecipientsSelectionViewModel.Factory
    let sharingService: SharingServiceProtocol
    let premiumService: PremiumServiceProtocol

    init(items: [VaultItem] = [],
         userGroupIds: Set<Identifier> = [],
         userEmails: Set<String> = [],
         sharingService: SharingServiceProtocol,
         premiumService: PremiumServiceProtocol,
         itemsViewModelFactory: ShareItemsSelectionViewModel.Factory,
         recipientsViewModelFactory: ShareRecipientsSelectionViewModel.Factory) {
        self.items = items
        self.recipientsConfiguration = .init(userEmails: userEmails, groupIds: userGroupIds)

        self.sharingService = sharingService
        self.premiumService = premiumService
        self.itemsViewModelFactory = itemsViewModelFactory
        self.recipientsViewModelFactory = recipientsViewModelFactory

        if self.items.isEmpty {
            self.composeSteps = [.items]
        } else {
            self.composeSteps = [.recipients]
        }
    }

    func makeItemsViewModel() -> ShareItemsSelectionViewModel {
        itemsViewModelFactory.make { [weak self] items in
            guard let self else {
                return
            }

            self.items = items
            self.composeSteps.append(.recipients)
        }
    }

    func makeRecipientsViewModel() -> ShareRecipientsSelectionViewModel {
        recipientsViewModelFactory.make(configuration: recipientsConfiguration) { [weak self] configuration in
            guard let self else {
                return
            }

            self.recipientsConfiguration = configuration
            self.share()
        }
    }

    func share() {
        Task {
            state = .sending
            let limit = premiumService.capability(for: \.sharingLimit).limit

            do {
                try await sharingService.share(items,
                                               recipients: Array(recipientsConfiguration.userEmails),
                                               userGroupIds: Array(recipientsConfiguration.groupIds),
                                               permission: recipientsConfiguration.permission,
                                               limitPerUser: limit)
                state = .success
            } catch SharingUpdaterError.sharingLimitReached {
                state = .composing
                errorMessage = L10n.Localizable.kwSharingPremiumLimit
            } catch let urlError as URLError where urlError.code == .notConnectedToInternet {
                state = .composing
                errorMessage = CoreLocalization.L10n.Core.kwNoInternet
            } catch {
                state = .composing
                errorMessage = L10n.Localizable.lockAlreadyAcquired
            }
        }

            }
}

extension ShareFlowViewModel {
    static func mock(items: [VaultItem] = [],
                     userGroupIds: Set<Identifier> = [],
                     userEmails: Set<String> = [],
                     sharingService: SharingServiceProtocol = SharingServiceMock()) -> ShareFlowViewModel {
        ShareFlowViewModel(
            items: items,
            userGroupIds: userGroupIds,
            userEmails: userEmails,
            sharingService: sharingService,
            premiumService: PremiumServiceMock(),
            itemsViewModelFactory: .init { .mock(completion: $0) },
            recipientsViewModelFactory: .init { .mock(sharingService: sharingService, configuration: $0, completion: $1) })
    }
}

extension Capability<LimitInfo> {
    var limit: Int? {
        enabled ? info?.limit : nil
    }
}
