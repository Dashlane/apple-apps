import Combine
import CoreData
import CorePersonalData
import CoreSession
import CoreSettings
import DashTypes
import Foundation
import SecurityDashboard

class BreachesStore: SecurityDashboard.BreachesStore {

  var lastRevisionForPublicBreaches: Int? {
    get {
      let value: Int? = DispatchQueue.main.sync { self.settings[.lastRevisionForPublicBreaches] }
      log.debug("lastRevisionForPublicBreaches used is \(value ?? -1)")
      return value
    }
    set {
      log.debug("Setting lastRevisionForPublicBreaches to \(newValue ?? -1)")
      DispatchQueue.main.sync {
        self.settings[.lastRevisionForPublicBreaches] = newValue
      }
    }
  }

  var lastUpdateDateForDataLeakBreaches: TimeInterval? {
    get {
      let value: TimeInterval? = DispatchQueue.main.sync {
        self.settings[.lastUpdateDataForDataLeaks]
      }
      log.debug("lastRevisionForPublicBreaches used is \(value ?? -1)")
      return value
    }
    set {
      log.debug("Setting lastUpdateDateForDataLeakBreaches to \(newValue ?? -1)")
      DispatchQueue.main.sync {
        self.settings[.lastUpdateDataForDataLeaks] = newValue
      }
    }
  }

  private let session: Session
  private let settings: KeyedSettings<BreachSettingsKey>
  private let database: ApplicationDatabase
  private let log: Logger
  private let breachContentDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    return decoder
  }()
  private let breachContentEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .secondsSince1970
    return encoder
  }()
  private var subscriptions = Set<AnyCancellable>()

  init(
    session: Session,
    database: ApplicationDatabase,
    settings: LocalSettingsStore,
    log: Logger
  ) {
    self.session = session
    self.database = database
    self.log = log
    self.settings = settings.keyed(by: BreachSettingsKey.self)
  }

  func breachesPublisher() -> AnyPublisher<Set<StoredBreach>, Never> {
    database.itemsPublisher(for: SecurityBreach.self)
      .receive(on: DispatchQueue.global(qos: .userInitiated))
      .map { breaches in
        let storedBreaches = breaches.compactMap {
          $0.storedBreach(using: self.breachContentDecoder)
        }
        let mergedBreaches = storedBreaches.merged()
        return mergedBreaches
      }
      .eraseToAnyPublisher()
  }

  func fetch() -> Set<StoredBreach> {
    assert(!Thread.isMainThread)

    do {
      let storedBreaches = try database.fetchAll(SecurityBreach.self)
        .compactMap { $0.storedBreach(using: breachContentDecoder) }

      let mergedBreaches = storedBreaches.merged()
      return mergedBreaches
    } catch {
      self.log.error("Failed to read breaches", error: error)
      return []
    }
  }

  func create(_ breaches: Set<StoredBreach>) {
    assert(!Thread.isMainThread)

    let securityBreaches = breaches.compactMap {
      SecurityBreach(storedBreach: $0, encoder: breachContentEncoder)
    }

    do {
      _ = try database.save(securityBreaches)
    } catch {
      self.log.error("Failed to save breaches", error: error)
    }
  }

  func update(_ breaches: Set<StoredBreach>) {
    assert(!Thread.isMainThread)

    let securityBreaches: [SecurityBreach] = breaches.compactMap {
      guard let identifier = $0.objectID as? BreachStoreIdentifier else {
        return nil
      }
      guard var securityBreach = try? database.fetch(with: identifier.id, type: SecurityBreach.self)
      else {
        return nil
      }
      securityBreach.update(with: $0, encoder: breachContentEncoder)
      return securityBreach
    }

    do {
      _ = try database.save(securityBreaches)
    } catch {
      self.log.error("Failed to update breaches", error: error)
    }
  }
}

extension SecurityBreach.Status {
  var storedBreachStatus: StoredBreach.Status {
    switch self {
    case .pending:
      return .pending
    case .viewed:
      return .viewed
    case .acknowledged:
      return .acknowledged
    case .solved:
      return .solved
    case .default:
      return .unknown
    }
  }
}

extension StoredBreach.Status {
  var securityBreachStatus: SecurityBreach.Status {
    switch self {
    case .pending:
      return .pending
    case .viewed:
      return .viewed
    case .acknowledged:
      return .acknowledged
    case .solved:
      return .solved
    case .unknown:
      return .default
    }
  }
}
extension StoredBreach.Status: Comparable {
  private var sortingValue: Int {
    switch self {
    case .pending:
      return 1
    case .viewed:
      return 2
    case .acknowledged:
      return 3
    case .solved:
      return 4
    case .unknown:
      return 0
    }
  }

  public static func < (lhs: StoredBreach.Status, rhs: StoredBreach.Status) -> Bool {
    return lhs.sortingValue < rhs.sortingValue
  }
}

extension Array where Element == StoredBreach {

  fileprivate func merged() -> Set<StoredBreach> {
    let dict = Dictionary(grouping: self, by: { $0.breachID }).compactMap { $0.value.merge() }
    return Set(dict)
  }

  private func merge() -> StoredBreach? {
    guard !isEmpty else {
      return nil
    }

    guard self.count != 1 else {
      return first
    }

    let sorted = self.sorted {
      if $0.lastModificationRevision == $1.lastModificationRevision {
        return $0.status < $1.status
      } else {
        return $0.lastModificationRevision < $1.lastModificationRevision
      }
    }

    guard let base = sorted.last, let objectID = base.objectID else {
      return nil
    }

    let leakedPasswords = sorted.flatMap { $0.leakedPasswords }

    return StoredBreach(
      objectID: objectID,
      breach: base.breach,
      leakedPasswords: Set(leakedPasswords),
      status: base.status)
  }
}

extension StoredBreach {
  fileprivate var lastModificationRevision: Int {
    return breach.lastModificationRevision ?? 0
  }
}
