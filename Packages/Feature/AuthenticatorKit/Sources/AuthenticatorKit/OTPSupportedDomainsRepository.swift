import Foundation

public struct OTPSupportedDomainsRepository {

  public let domains: Set<String>

  public init() {
    do {
      domains = try Self.parseDomains()
    } catch {
      fatalError("Unable to load/parse local otp-supported-domains file, \(error)")
    }
  }

  public func isOTPSupported(domain: String) -> Bool {
    return domains.contains(domain.lowercased())
  }

  private static func parseDomains() throws -> Set<String> {
    let url = Bundle.module.url(forResource: "otp-supported-domains", withExtension: "json")!

    let data = try Data(contentsOf: url)
    let websites = try JSONDecoder().decode(Set<Website>.self, from: data)
    return Set(websites.map { $0.domain })
  }
}

private struct Website: Decodable, Hashable {
  let domain: String
}
