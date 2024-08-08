import CoreLocalization
import CorePersonalData
import CorePremium
import CoreUserTracking
import DashTypes
import DesignSystem
import Foundation
import Logger

@MainActor
public class CollectionNamingViewModel: ObservableObject, VaultKitServicesInjecting {

  public enum Mode {
    case addition
    case edition(VaultCollection)
  }

  @Published
  var collectionName: String {
    didSet {
      updateErrorIfNeeded()
    }
  }

  @Published
  var showNamingError: Bool = false

  @Published
  var inProgress: Bool = false

  let mode: Mode

  private var collection: VaultCollection

  var availableUserSpaces: [UserSpace] {
    userSpacesService.configuration.availableSpaces.filter { $0 != .both }
  }

  var collectionUserSpace: UserSpace {
    get {
      userSpacesService.configuration.virtualUserSpace(for: collection)
        ?? userSpacesService.configuration.selectedSpace
    }
    set {
      collection.moveToSpace(withId: newValue.personalDataId)
    }
  }

  var isUserSpaceForced: Bool {
    if case .edition = mode {
      return true
    } else {
      return false
    }
  }

  var canBeCreatedOrSaved: Bool {
    !formattedCollectionName.isEmpty && !showNamingError
  }

  private var formattedCollectionName: String {
    collectionName.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private let logger: Logger
  private let activityReporter: ActivityReporterProtocol
  private let vaultCollectionDatabase: VaultCollectionDatabaseProtocol
  private let vaultCollectionsStore: VaultCollectionsStore
  private let userSpacesService: UserSpacesService

  private let vaultCollectionEditionServiceFactory: VaultCollectionEditionService.Factory

  public init(
    mode: CollectionNamingViewModel.Mode,
    logger: Logger,
    activityReporter: ActivityReporterProtocol,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    userSpacesService: UserSpacesService,
    vaultCollectionEditionServiceFactory: VaultCollectionEditionService.Factory
  ) {
    switch mode {
    case .addition:
      self.collectionName = ""
      let spaceId: String
      if userSpacesService.configuration.selectedSpace != .both {
        spaceId = userSpacesService.configuration.selectedSpace.personalDataId
      } else if let team = userSpacesService.configuration.currentTeam {
        spaceId = team.personalDataId
      } else {
        spaceId =
          UserSpace
          .personal.personalDataId
      }
      self.collection = .init(collection: PrivateCollection(spaceId: spaceId))
    case .edition(let collection):
      self.collectionName = collection.name
      self.collection = collection
    }
    self.mode = mode
    self.logger = logger
    self.activityReporter = activityReporter
    self.vaultCollectionDatabase = vaultCollectionDatabase
    self.vaultCollectionsStore = vaultCollectionsStore
    self.userSpacesService = userSpacesService
    self.vaultCollectionEditionServiceFactory = vaultCollectionEditionServiceFactory
  }

  private func updateErrorIfNeeded() {
    let collectionsInCurrentCollectionSpace = vaultCollectionsStore.collections.filter(
      bySpaceId: collectionUserSpace.personalDataId)
    if collectionsInCurrentCollectionSpace.contains(where: { $0.name == formattedCollectionName }) {
      if case .edition(let collection) = mode {
        showNamingError = formattedCollectionName != collection.name
      } else {
        showNamingError = true
      }
    } else {
      showNamingError = false
    }
  }
}

extension CollectionNamingViewModel {
  func cancel(completion: @escaping (CollectionNamingView.Completion) -> Void) {
    completion(.cancel)
  }

  func createOrSave(
    with toast: ToastAction, completion: @escaping (CollectionNamingView.Completion) -> Void
  ) {
    guard canBeCreatedOrSaved else { return }
    inProgress = true
    Task {
      do {
        switch mode {
        case .addition:
          try await vaultCollectionDatabase.createPrivateCollection(
            collection,
            named: formattedCollectionName
          )
          toast(
            L10n.Core.KWVaultItem.Collections.created(formattedCollectionName),
            image: .ds.feedback.success.outlined)
        case .edition(let collection):
          let vaultCollectionEditionService = vaultCollectionEditionServiceFactory.make(
            collection: collection)
          try await vaultCollectionEditionService.rename(to: formattedCollectionName)
          toast(L10n.Core.KWVaultItem.Changes.saved, image: .ds.feedback.success.outlined)
        }
        reportCreationOrSaving()
        completion(.done(collection))
      } catch {
        logger[.personalData].error("Error on save", error: error)
      }
      inProgress = false
    }
  }

  private func reportCreationOrSaving() {
    let action: Definition.CollectionAction
    switch mode {
    case .addition:
      action = .add
    case .edition:
      action = .edit
    }

    let event = UserEvent.UpdateCollection(
      action: action,
      collectionId: collection.id.rawValue,
      isShared: collection.isShared,
      itemCount: collection.itemIds.count
    )

    activityReporter.report(event)
  }
}

extension CollectionNamingViewModel {
  public static func mock(mode: Mode) -> CollectionNamingViewModel {
    .init(
      mode: mode,
      logger: LoggerMock(),
      activityReporter: .mock,
      vaultCollectionDatabase: MockVaultKitServicesContainer().vaultCollectionDatabase,
      vaultCollectionsStore: MockVaultKitServicesContainer().vaultCollectionsStore,
      userSpacesService: MockVaultKitServicesContainer().userSpacesService,
      vaultCollectionEditionServiceFactory: .init { .mock($0) }
    )
  }
}
