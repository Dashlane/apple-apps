import Combine
import CoreIPC
import DashTypes
import Foundation
import TOTPGenerator

public protocol AuthenticatorDatabaseServiceProtocol {
  var login: String? { get }
  var codes: Set<OTPInfo> { get }
  var codesPublisher: AnyPublisher<Set<OTPInfo>, Never> { get }
  var isLoadedPublisher: AnyPublisher<Bool, Never> { get }
  func delete(_ item: OTPInfo) throws
  func add(_ items: [OTPInfo]) throws
  func update(_ item: OTPInfo) throws
  func load()
}

public class AuthenticatorDatabaseService: AuthenticatorDatabaseServiceProtocol, ObservableObject {
  public let login: String? = nil

  @Published
  public var codes: Set<OTPInfo> = []
  public var codesPublisher: AnyPublisher<Set<OTPInfo>, Never> { $codes.eraseToAnyPublisher() }
  public let persistor: Persistor

  @Published
  public var isLoaded = false
  public var isLoadedPublisher: AnyPublisher<Bool, Never> { $isLoaded.eraseToAnyPublisher() }

  var subscriptions = Set<AnyCancellable>()

  public init(
    logger: Logger,
    storeURL: URL,
    makeCryptoEngine: (_ encryptionKeyId: String) -> CryptoEngine,
    shouldLoadDatabase: Bool = true
  ) {
    let engine = makeCryptoEngine("dashlaneAuthenticatorDBKey")
    self.persistor = OnDiskPersistor(
      persistedURL: storeURL,
      coder: JSONMessageCoder(logger: logger, engine: engine))
    if shouldLoadDatabase {
      load()
    }
  }

  public func delete(_ item: OTPInfo) {
    let filteredCodes = codes.filter { $0 != item }
    self.codes = filteredCodes
    let otpList = codes.map(PersistedOTPInformation.init)
    try? persistor.save(PersistedItems(items: otpList))
  }

  public func add(_ items: [OTPInfo]) throws {
    codes.formUnion(items)
    let otpList = codes.map(PersistedOTPInformation.init)
    try persistor.save(PersistedItems(items: otpList))
  }

  public func update(_ item: OTPInfo) throws {
    self.codes = codes.filter({ $0.id != item.id }).union([item])
    let otpList = codes.map(PersistedOTPInformation.init)
    try persistor.save(PersistedItems(items: otpList))
  }

  public func load() {
    persistor.load { (items: PersistedItems<PersistedOTPInformation>?) in
      defer { isLoaded = true }
      guard let items = items else {
        return
      }
      codes = Set(
        items.items.compactMap { item in
          guard
            let conf = try? OTPConfiguration(
              otpURL: item.otpURL,
              supportDashlane2FA: true,
              defaultTitle: item.title,
              defaultLogin: item.login,
              defaultIssuer: item.issuer)
          else {
            return nil
          }
          return OTPInfo(
            id: item.id, configuration: conf, isFavorite: item.isFavorite ?? false,
            recoveryCodes: item.recoveryCodes)
        })
    }
  }
}

extension PersistedOTPInformation {
  public init(_ otpInfo: OTPInfo) {
    self.id = otpInfo.id
    self.otpURL = otpInfo.configuration.otpURL
    self.recoveryCodes = otpInfo.recoveryCodes
    self.isFavorite = otpInfo.isFavorite
    self.login = otpInfo.configuration.login
    self.issuer = otpInfo.configuration.issuer
    self.title = otpInfo.configuration.title
  }
}

public class AuthenticatorDatabaseServiceMock: ObservableObject,
  AuthenticatorDatabaseServiceProtocol
{
  public let login: String? = nil

  public var codesPublisher: AnyPublisher<Set<OTPInfo>, Never> {
    $codes.eraseToAnyPublisher()
  }

  @Published
  public var codes: Set<OTPInfo> = [
    OTPInfo.mock,
    OTPInfo.mock,
    OTPInfo.mock,
  ]

  @Published
  public var isLoaded = false
  public var isLoadedPublisher: AnyPublisher<Bool, Never> { $isLoaded.eraseToAnyPublisher() }

  public func delete(_ item: OTPInfo) {
    codes = codes.filter { $0 != item }
  }

  public func add(_ items: [OTPInfo]) {
    codes.formUnion(items)
  }

  public func update(_ item: OTPInfo) throws {
    self.codes = codes.filter({ $0.id != item.id }).union([item])
  }

  public func load() {
    isLoaded = true
  }

  public init() {

  }
}
