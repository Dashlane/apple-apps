import Combine
import Contacts
import CoreLocalization
import CorePremium
import CoreSession
import CoreSharing
import CoreTypes
import Foundation
import VaultKit

@MainActor
class ShareRecipientsSelectionViewModel: ObservableObject, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  public struct InfoboxContent {
    let title: String
    let text: String
  }

  @Published
  var configuration = RecipientsConfiguration()

  @Published
  var groups: [SharingEntitiesUserGroup] = []

  @Published
  var emailRecipients: [EmailRecipientInfo] = []
  @Published
  var customEmailRecipients: Set<EmailRecipient> = []

  @Published
  var search: String = ""

  @Published
  var infoboxContent: InfoboxContent?

  var showPermissionLevelSelector: Bool
  var showTeamOnly: Bool
  var teamLogins: [String]?

  var placeholderText: String {
    premiumStatusProvider.status.b2bStatus?.statusCode == .inTeam
      ? CoreL10n.kwSharingComposeMessageToFieldPlaceholderB2B
      : CoreL10n.kwSharingComposeMessageToFieldPlaceholderB2C
  }

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

  var isLoaded: Bool = false

  let gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory

  let completion: @MainActor (RecipientsConfiguration) -> Void

  private let login: Login
  private let sharingService: SharingServiceProtocol
  private let premiumStatusProvider: PremiumStatusProvider
  private let contactProvider = SystemContactRecipientProvider()
  private let computingQueue = DispatchQueue(label: "com.dashlane.new-share", qos: .userInitiated)

  init(
    session: Session,
    configuration: RecipientsConfiguration = .init(),
    showPermissionLevelSelector: Bool = true,
    showTeamOnly: Bool = false,
    sharingService: SharingServiceProtocol,
    premiumStatusProvider: PremiumStatusProvider,
    gravatarIconViewModelFactory: GravatarIconViewModel.SecondFactory,
    completion: @escaping @MainActor (RecipientsConfiguration) -> Void
  ) {
    self.login = session.login
    self.configuration = configuration
    self.showPermissionLevelSelector = showPermissionLevelSelector
    self.showTeamOnly = showTeamOnly
    self.sharingService = sharingService
    self.premiumStatusProvider = premiumStatusProvider
    self.gravatarIconViewModelFactory = gravatarIconViewModelFactory
    self.completion = completion

    Task {
      await configurePublishers()
    }
  }

  func configurePublishers() async {
    let searchPublisher = $search.dropFirst().debounce(
      for: .seconds(0.3), scheduler: DispatchQueue.main
    )
    .map { $0.lowercased() }
    .prepend("")
    .receive(on: computingQueue)
    .shareReplayLatest()

    if showTeamOnly {
      do {
        teamLogins = try await sharingService.getTeamLogins().map { $0.lowercased() }
        configureGroups(usingSearchPublisher: searchPublisher)
        configureTeamRecipients(usingSearchPublisher: searchPublisher)

      } catch {
        assertionFailure(error.localizedDescription)
      }
    } else {
      configureGroups(usingSearchPublisher: searchPublisher)
      configureEmailRecipients(usingSearchPublisher: searchPublisher)
    }

    $configuration
      .combineLatest($search, premiumStatusProvider.statusPublisher) {
        (configuration, search, status) -> InfoboxContent? in
        if !configuration.isEmpty
          && search.isEmpty
          && status.isConcernedByStarterPlanSharingLimit
          && status.b2bStatus?.currentTeam?.isAdminOfAStarterTeam == true
        {
          return Self.starterAdminInfo
        } else if !configuration.isEmpty
          && search.isEmpty
          && status.b2bStatus?.currentTeam?.isAdminOfABusinessTeamInTrial == true
        {
          return Self.businessTrialInfo
        } else if configuration.sharingType == .collection {
          return Self.collectionInfo
        } else {
          return nil
        }
      }
      .assign(to: &$infoboxContent)
  }

  private func configureGroups<P: Publisher>(usingSearchPublisher searchPublisher: P)
  where P.Output == String, P.Failure == Never {
    searchPublisher
      .combineLatest(sharingService.sharingUserGroupsPublisher().receive(on: computingQueue)) {
        [showTeamOnly, teamLogins] search, groups in
        var displayedGroups = groups
        if showTeamOnly == true, let teamLogins = teamLogins {
          displayedGroups = displayedGroups.filter({ group in
            group.users.allSatisfy { teamLogins.contains($0.email.lowercased()) }
          })
        }

        return displayedGroups.filter(using: search)
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$groups)
  }

  private func configureTeamRecipients<P: Publisher>(usingSearchPublisher searchPublisher: P)
  where P.Output == String, P.Failure == Never {
    searchPublisher
      .map { [weak self] search in
        var recipients = (self?.teamLogins ?? [])
          .map { member in
            EmailRecipient(label: member, email: member, image: nil, origin: .sharing)
          }
          .sorted()

        if !search.isEmpty {
          recipients = recipients.search(using: search)
        }

        self?.isLoaded = true

        return recipients.map { recipient in
          .init(recipient: recipient, action: .toggle(removable: false))
        }
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$emailRecipients)
  }

  private func configureEmailRecipients<P: Publisher>(usingSearchPublisher searchPublisher: P)
  where P.Output == String, P.Failure == Never {
    let databaseEmailRecipientsPublisher = self.sharingService.sharingUsersPublisher().map {
      users in
      Set(users.map { EmailRecipient(label: nil, email: $0.id, image: nil, origin: .sharing) })
    }.receive(on: computingQueue)

    searchPublisher.combineLatest(
      databaseEmailRecipientsPublisher, $customEmailRecipients.receive(on: computingQueue)
    ) {
      [contactProvider, login]
      (
        search: String, databaseRecipients: Set<EmailRecipient>,
        customRecipients: Set<EmailRecipient>
      ) in
      var recipients: [EmailRecipient]

      if search.isEmpty {
        recipients = Array(databaseRecipients) + Array(customRecipients)
        recipients = recipients.sorted()
      } else {
        let filteredRecipients = Set(
          databaseRecipients.search(using: search) + customRecipients.search(using: search))
        let recipientsFromSystemContact = Set(
          contactProvider.search(search).filter { $0.email != login.email })
        let allRecipients = Array(Set(recipientsFromSystemContact).union(filteredRecipients))

        let recipientForSearch = EmailRecipient(
          label: nil, email: search, image: nil, origin: .searchField)

        if Email(search).isValid, search != login.email,
          !filteredRecipients.contains(recipientForSearch)
        {
          recipients = [recipientForSearch] + filteredRecipients
        } else {
          recipients = allRecipients
        }
      }

      self.isLoaded = true

      return Array(
        recipients: recipients,
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

  func toggle(_ group: SharingEntitiesUserGroup) {
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
  static func mock(
    sharingService: SharingServiceProtocol,
    configuration: RecipientsConfiguration = .init(),
    completion: @escaping @MainActor (RecipientsConfiguration) -> Void = { _ in }
  ) -> ShareRecipientsSelectionViewModel {
    ShareRecipientsSelectionViewModel(
      session: .mock,
      sharingService: sharingService,
      premiumStatusProvider: .mock(),
      gravatarIconViewModelFactory: .init { email in .mock(email: email) },
      completion: completion
    )
  }
}

extension ShareRecipientsSelectionViewModel {
  static var collectionInfo: InfoboxContent {
    InfoboxContent(
      title: CoreL10n.kwSharingCollectionPermissionTitle,
      text: CoreL10n.kwSharingCollectionPermissionText)
  }
  static var starterAdminInfo: InfoboxContent {
    InfoboxContent(
      title: CoreL10n.starterLimitationAdminSharingWarningTitle,
      text: CoreL10n.starterLimitationAdminSharingWarningDescription)
  }
  static var businessTrialInfo: InfoboxContent {
    InfoboxContent(
      title: CoreL10n.starterLimitationBusinessAdminTrialSharingWarningTitle,
      text: CoreL10n.starterLimitationBusinessAdminTrialSharingWarningDescription)
  }
}

extension Array where Element == SharingEntitiesUserGroup {
  func filter(using text: String) -> [SharingEntitiesUserGroup] {
    if text.isEmpty {
      return self
    } else {
      return self.filter { $0.name.lowercased().contains(text) }
    }
  }
}

extension Collection where Element == EmailRecipient {
  func search(using text: String) -> [EmailRecipient] {
    let filteredList: [(element: EmailRecipient, match: EmailRecipient.EmailMatch)] = compactMap {
      element in
      if let match = element.match(text) {
        return (element: element, match: match)
      } else {
        return nil
      }
    }
    return
      filteredList
      .sorted(by: { $0.match.rawValue < $1.match.rawValue })
      .map { $0.element }
  }
}

extension [EmailRecipientInfo] {
  init(
    recipients: [EmailRecipient],
    databaseRecipients: Set<EmailRecipient>,
    customRecipients: Set<EmailRecipient>
  ) {
    self = recipients.map { recipient in
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
