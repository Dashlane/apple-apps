import CoreTypes
import DomainParser
import Foundation

public protocol PersonalDataURLDecoderProtocol {
  func decodeURL(_ url: String) throws -> PersonalDataURL
}

public struct PersonalDataURLDecoderMock: PersonalDataURLDecoderProtocol {
  let personalDataURL: PersonalDataURL?

  public func decodeURL(_ url: String) throws -> PersonalDataURL {
    personalDataURL ?? PersonalDataURL(rawValue: url)
  }

  public init(personalDataURL: PersonalDataURL?) {
    self.personalDataURL = personalDataURL
  }
}

extension PersonalDataURLDecoderProtocol where Self == PersonalDataURLDecoderMock {
  public static func mock(url: PersonalDataURL? = nil) -> PersonalDataURLDecoderMock {
    return PersonalDataURLDecoderMock(personalDataURL: url)
  }
}

public struct PersonalDataURLDecoder: PersonalDataURLDecoderProtocol {

  let domainParser: DomainParserProtocol

  public init(domainParser: DomainParserProtocol) {
    self.domainParser = domainParser
  }

  public func decodeURL(_ url: String) throws -> PersonalDataURL {
    var domain: Domain?
    let urlHost = domainParser.parseHost(urlString: url)
    if let urlHost = urlHost {
      domain = domainParser.parse(urlHost: urlHost)
    }
    if let parsedDomain = domain {
      domain = Domain(name: parsedDomain.name, publicSuffix: parsedDomain.publicSuffix)
    }
    return PersonalDataURL(rawValue: url, domain: domain, host: urlHost)
  }
}

public struct DomainParserContainer: DomainParserProtocol {

  public static var domainParser = try! DomainParser(quickParsing: true)

  public init() {}

  public func parse(host: String) -> ParsedHost? {
    Self.domainParser.parse(host: host)
  }
}

extension DomainParserProtocol {
  fileprivate func parseHost(urlString: String) -> String? {
    guard
      let escapedURLString = urlString.addingPercentEncoding(
        withAllowedCharacters: .urlQueryAllowed),
      let url = URL(
        string: escapedURLString.starts(with: "http") ? escapedURLString : "_" + escapedURLString),
      let urlHost = url.host?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    else {
      return nil
    }
    return urlHost
  }

  fileprivate func parse(urlHost: String) -> Domain? {
    guard let parsedHost = parse(host: urlHost),
      let domain = parsedHost.domain
    else {
      return Domain(name: urlHost, publicSuffix: nil)
    }

    return Domain(name: domain, publicSuffix: parsedHost.publicSuffix)
  }

  public func parse(urlString: String) -> Domain? {
    guard let host = parseHost(urlString: urlString) else { return nil }
    let domain = parse(urlHost: host)
    return domain
  }
}
