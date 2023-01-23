import Foundation
import CoreSharing
import VaultKit
import DashTypes
import Contacts
import Combine
import CoreSession

@MainActor
class ShareRecipientsSelectionViewModel: ObservableObject, SessionServicesInjecting, MockVaultConnectedInjecting {
    @Published
    var configuration = RecipientsConfiguration()

    @Published
    var groups: [SharingItemsUserGroup] = []

    @Published
    var emailRecipients: [EmailRecipientInfo] = []
    @Published
    var customEmailRecipients: Set<EmailRecipient> = []

    @Published
    var search: String = ""

        var isSearchInsertable: Bool {
        recipientsCount == 1
    }

    var hasNoRecipients: Bool {
        emailRecipients.isEmpty && groups.isEmpty
    }

    var recipientsCount: Int {
        emailRecipients.count + groups.count
    }

    var isReadyToShare: Bool {
        !configuration.isEmpty && search.isEmpty
    }

    let gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory

    let completion: @MainActor (RecipientsConfiguration) -> Void

    private let login: Login
    private let sharingService: SharingServiceProtocol
    private let contactProvider = SystemContactRecipientProvider()
    private let computingQueue = DispatchQueue(label: "com.dashlane.new-share", qos: .userInitiated)

    init(session: Session,
         configuration: RecipientsConfiguration = .init(),
         sharingService: SharingServiceProtocol,
         gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory,
         completion: @escaping @MainActor (RecipientsConfiguration) -> Void) {
        self.login = session.login
        self.configuration = configuration
        self.sharingService = sharingService
        self.gravatarIconViewModelFactory = gravatarIconViewModelFactory
        self.completion = completion
        configurePublishers()
    }

        private func configurePublishers() {
                let searchPublisher = $search.dropFirst().debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .map { $0.lowercased() }
            .prepend("") 
            .receive(on: computingQueue)
            .shareReplayLatest()

        configureGroups(usingSearchPublisher: searchPublisher)
        configureEmailRecipients(usingSearchPublisher: searchPublisher)
    }

    private func configureGroups<P: Publisher>(usingSearchPublisher searchPublisher: P) where P.Output == String, P.Failure == Never {
        searchPublisher.combineLatest(sharingService.sharingUserGroupsPublisher().receive(on: computingQueue)) { search, groups in
            return groups.filter(using: search)
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$groups)
    }

        private func configureEmailRecipients<P: Publisher>(usingSearchPublisher searchPublisher: P) where P.Output == String, P.Failure == Never {
        let databaseEmailRecipientsPublisher = self.sharingService.sharingUsersPublisher().map { users in
            Set(users.map { EmailRecipient(label: nil, email: $0.id, image: nil, origin: .sharing) })
        }.receive(on: computingQueue)

        searchPublisher.combineLatest(databaseEmailRecipientsPublisher, $customEmailRecipients.receive(on: computingQueue)) { [contactProvider, login] (search: String, databaseRecipients: Set<EmailRecipient>, customRecipients: Set<EmailRecipient>) in
            let recipients: [EmailRecipient]

            if search.isEmpty {
                recipients = Array(databaseRecipients) + Array(customRecipients)
            } else {
                                let filteredRecipients = Set(databaseRecipients.filter(using: search) + customRecipients.filter(using: search))
                let recipientsFromSystemContact = Set(contactProvider.search(search).filter { $0.email != login.email })
                let allRecipients = Set(recipientsFromSystemContact).union(filteredRecipients).sorted()

                let recipientForSearch = EmailRecipient(label: nil, email: search, image: nil, origin: .searchField)

                                if Email(search).isValid, search != login.email, !filteredRecipients.contains(recipientForSearch) {
                    recipients = [recipientForSearch] + filteredRecipients
                } else {
                    recipients = allRecipients
                }
            }

            return Array(recipients: recipients,
                         databaseRecipients: databaseRecipients,
                         customRecipients: customRecipients)
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$emailRecipients)
    }

        func add(_ recipient: EmailRecipient) {
        configuration.userEmails.insert(recipient.email)
        customEmailRecipients.insert(recipient)
    }

    func remove(_ recipient: EmailRecipient) {
        customEmailRecipients.remove(recipient)
        configuration.userEmails.remove(recipient.email)
    }

    func addCurrentSearch() {
        guard isSearchInsertable else {
            return
        }

        if let emailRecipientInfo = emailRecipients.first {
            if case EmailRecipientInfo.Action.add = emailRecipientInfo.action {
                add(emailRecipientInfo.recipient)
            } else if !configuration.userEmails.contains(emailRecipientInfo.recipient.email) {
                toggle(emailRecipientInfo.recipient)
            }
        } else if let group = groups.first, !configuration.groupIds.contains(group.id) {
            toggle(group)
        }

        search = ""
    }

        func toggle(_ group: SharingItemsUserGroup) {
        if configuration.groupIds.contains(group.id) {
            configuration.groupIds.remove(group.id)
        } else {
            configuration.groupIds.insert(group.id)
        }
    }

    func toggle(_ recipient: EmailRecipient) {
        if configuration.userEmails.contains(recipient.email) {
            configuration.userEmails.remove(recipient.email)
        } else {
            configuration.userEmails.insert(recipient.email)
        }
    }

    func share() {
        completion(configuration)
    }
}

extension ShareRecipientsSelectionViewModel {
    static func mock(sharingService: SharingServiceProtocol,
                     configuration: RecipientsConfiguration = .init(),
                     completion: @escaping @MainActor (RecipientsConfiguration) -> Void = { _ in  }) -> ShareRecipientsSelectionViewModel {
        ShareRecipientsSelectionViewModel(session: .mock,
                                          sharingService: sharingService,
                                          gravatarIconViewModelFactory: .init({ email in
                .mock(email: email)
        }), completion: completion)
    }
}

extension Array where Element == SharingItemsUserGroup {
    func filter(using text: String) -> [SharingItemsUserGroup] {
        if text.isEmpty {
            return self
        } else {
            return self.filter { $0.name.lowercased().contains(text) }
        }
    }
}

extension Collection where Element == EmailRecipient {
    func filter(using text: String) -> [EmailRecipient] {
        return filter { $0.match(text) }
    }
}

extension [EmailRecipientInfo] {
    init(recipients: [EmailRecipient],
         databaseRecipients: Set<EmailRecipient>,
         customRecipients: Set<EmailRecipient>) {
        self = recipients.sorted().map { recipient in
            let action: EmailRecipientInfo.Action

            let inDB = databaseRecipients.contains(recipient)
            let isCustom = inDB ? false : customRecipients.contains(recipient)

            if inDB || isCustom {
                action = .toggle(removable: isCustom)
            } else {
                action = .add
            }

            return EmailRecipientInfo(recipient: recipient, action: action)
        }
    }
}
