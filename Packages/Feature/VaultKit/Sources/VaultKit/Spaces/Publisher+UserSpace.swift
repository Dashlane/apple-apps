import Combine
import CorePersonalData
import CorePremium
import Foundation

extension Array where Element == VaultItem {
  fileprivate func filter(by configuration: UserSpacesService.SpacesConfiguration) -> [VaultItem] {
    self.filter { configuration.shouldDisplay($0) }
  }
}

extension Publisher where Output == [VaultItem], Failure == Never {
  public func filter<SpacePublisher: Publisher>(by configuration: SpacePublisher) -> AnyPublisher<
    [VaultItem], Failure
  >
  where
    SpacePublisher.Output == UserSpacesService.SpacesConfiguration,
    SpacePublisher.Failure == Failure
  {
    return self.combineLatest(configuration) { items, configuration in
      return items.filter(by: configuration)
    }.eraseToAnyPublisher()
  }
}

extension Collection where Element: VaultItem {
  fileprivate func filter(by configuration: UserSpacesService.SpacesConfiguration) -> [Element] {
    self.filter { configuration.shouldDisplay($0) }
  }
}

extension Publisher where Output: Collection, Output.Element: VaultItem, Failure == Never {
  public func filter<SpacePublisher: Publisher>(by configuration: SpacePublisher) -> AnyPublisher<
    [Output.Element], Failure
  >
  where
    SpacePublisher.Output == UserSpacesService.SpacesConfiguration,
    SpacePublisher.Failure == Failure
  {
    return self.combineLatest(configuration) { items, configuration in
      return items.filter(by: configuration)
    }.eraseToAnyPublisher()
  }
}

extension Array where Element == PrivateCollection {
  fileprivate func filter(by configuration: UserSpacesService.SpacesConfiguration)
    -> [PrivateCollection]
  {
    self.filter { configuration.shouldDisplay($0) }
  }
}

extension Publisher where Output == [PrivateCollection], Failure == Never {
  public func filter<SpacePublisher: Publisher>(by configuration: SpacePublisher) -> AnyPublisher<
    [PrivateCollection], Failure
  >
  where
    SpacePublisher.Output == UserSpacesService.SpacesConfiguration,
    SpacePublisher.Failure == Failure
  {
    return self.combineLatest(configuration) { collections, configuration in
      return collections.filter(by: configuration)
    }.eraseToAnyPublisher()
  }
}

extension Publisher where Output == [DataSection], Failure == Never {
  public func filter<SpacePublisher: Publisher>(by configuration: SpacePublisher) -> AnyPublisher<
    [DataSection], Failure
  >
  where
    SpacePublisher.Output == UserSpacesService.SpacesConfiguration,
    SpacePublisher.Failure == Failure
  {
    return self.combineLatest(configuration) { sections, configuration in
      return sections.map {
        DataSection(
          name: $0.name, listIndex: $0.listIndex, items: $0.items.filter(by: configuration))
      }
    }.eraseToAnyPublisher()
  }
}
