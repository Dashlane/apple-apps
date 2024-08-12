import Combine
import CorePremium

extension Publisher where Output == [VaultCollection], Failure == Never {
  public func filter<SpacePublisher: Publisher>(
    by space: SpacePublisher
  ) -> AnyPublisher<[VaultCollection], Failure>
  where
    SpacePublisher.Output == UserSpacesService.SpacesConfiguration,
    SpacePublisher.Failure == Failure
  {
    return self.combineLatest(space) { collections, configuration in
      return collections.filter(by: configuration.selectedSpace)
    }
    .eraseToAnyPublisher()
  }
}
