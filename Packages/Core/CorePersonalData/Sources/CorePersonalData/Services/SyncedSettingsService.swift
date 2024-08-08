import Combine
import DashTypes
import Foundation

public final class SyncedSettingsService {
  let database: ApplicationDatabase
  let logger: Logger

  public let didChange = PassthroughSubject<Void, Never>()

  private var subscription: AnyCancellable?
  private var settings: Settings {
    didSet {
      guard oldValue != settings else {
        return
      }

      self.didChange.send()
    }
  }

  public init(
    database: ApplicationDatabase,
    initialSettings: Settings,
    logger: Logger
  ) {
    self.database = database
    settings = initialSettings
    self.logger = logger
    subscription =
      database
      .itemPublisher(for: initialSettings.id, type: Settings.self)
      .ignoreError()
      .receive(on: DispatchQueue.main)
      .assign(to: \.settings, on: self)
  }

  private func save() {
    do {
      settings = try self.database.save(settings)
    } catch {
      logger.error("Cannot save settings", error: error)
    }
  }

  public subscript<T>(keyPath: WritableKeyPath<Settings, T>) -> T {
    get {
      return settings[keyPath: keyPath]
    }
    set {
      settings[keyPath: keyPath] = newValue
      save()
    }
  }

  public subscript<T>(keyPath: KeyPath<Settings, T>) -> T {
    return settings[keyPath: keyPath]
  }

  public func changes<T: Hashable>(of keyPath: KeyPath<Settings, T>) -> some Publisher<T, Never> {
    didChange
      .map {
        self[keyPath]
      }
      .removeDuplicates()
  }
}

extension SyncedSettingsService {
  public convenience init(
    logger: Logger,
    database: ApplicationDatabase
  ) throws {
    guard let settings = try database.fetch(with: Settings.id, type: Settings.self) else {
      throw SyncedSettingsService.Error.settingsNotFound
    }

    self.init(
      database: database,
      initialSettings: settings,
      logger: logger)
  }
}

extension SyncedSettingsService {
  public static var mock: SyncedSettingsService {
    SyncedSettingsService(
      database: ApplicationDBStack.mock(),
      initialSettings: Settings(cryptoConfig: .init(fixedSalt: nil, marker: ""), email: "_"),
      logger: LoggerMock())
  }
}

extension SyncedSettingsService {
  public enum Error: Swift.Error {
    case settingsNotFound
  }
}
