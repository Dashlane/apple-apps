import Combine
import CorePersonalData
import CorePremium
import Foundation

@MainActor
public class CollectionRowViewModel: ObservableObject, VaultKitServicesInjecting {

  @Published
  var collection: VaultCollection

  var shouldShowSpace: Bool {
    userSpacesService.configuration.availableSpaces.count > 1
  }

  var space: UserSpace? {
    userSpacesService.configuration.displayedUserSpace(for: collection)
  }

  private let userSpacesService: UserSpacesService

  public init(
    collection: VaultCollection,
    userSpacesService: UserSpacesService
  ) {
    self.collection = collection
    self.userSpacesService = userSpacesService
  }
}

extension CollectionRowViewModel {
  static func mock(collection: VaultCollection) -> CollectionRowViewModel {
    .init(
      collection: collection,
      userSpacesService: MockVaultKitServicesContainer().userSpacesService
    )
  }
}
