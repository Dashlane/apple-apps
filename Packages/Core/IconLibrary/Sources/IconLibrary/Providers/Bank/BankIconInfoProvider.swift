import DashTypes
import Foundation

public struct BankIconInfoProvider: IconInfoProvider {
  static let baseURL = URL(string: "_")!
  public struct Request: IconLibraryRequest {
    public let bankCode: String
    public let isWhiteMode: Bool
    public var cacheKey: String {
      return bankCode + imageSuffix
    }

    var imageSuffix: String {
      return isWhiteMode ? "_white" : ""
    }

    public init(
      bankCode: String,
      isWhiteMode: Bool = false
    ) {
      self.bankCode = bankCode
      self.isWhiteMode = isWhiteMode
    }
  }

  public func iconInfo(for request: Request) async throws -> (URL, IconColorSet?)? {
    let url = BankIconInfoProvider.baseURL.appendingPathComponent(
      "bank_\(request.bankCode)\(request.imageSuffix).tiff")
    return (url, nil)
  }
}

@available(macOS 10.15, *)
public typealias BankIconLibrary = IconLibrary<BankIconInfoProvider>

@available(macOS 10.15, *)
extension IconLibrary where Provider == BankIconInfoProvider {
  public init(
    cacheDirectory: URL,
    cacheValidationInterval: TimeInterval = Self.defaultCacheValidationInterval,
    cryptoEngine: CryptoEngine,
    logger: Logger
  ) {

    self.init(
      cacheDirectory: cacheDirectory,
      cacheValidationInterval: cacheValidationInterval,
      cryptoEngine: cryptoEngine,
      imageDownloader: FileDownloader(),
      provider: BankIconInfoProvider(),
      logger: logger)
  }

  public func icon(forBankCode bankCode: String, isWhiteMode: Bool = false) async throws -> Icon? {
    let request = BankIconLibrary.Request(bankCode: bankCode, isWhiteMode: isWhiteMode)
    return try await icon(for: request)
  }
}
