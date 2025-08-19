import Foundation

extension AppAPIClient.Killswitch {
  public struct GetKillSwitches: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/killswitch/GetKillSwitches"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(requestedKillswitches: [String], timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(requestedKillswitches: requestedKillswitches)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getKillSwitches: GetKillSwitches {
    GetKillSwitches(api: api)
  }
}

extension AppAPIClient.Killswitch.GetKillSwitches {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case requestedKillswitches = "requestedKillswitches"
    }

    public let requestedKillswitches: [String]

    public init(requestedKillswitches: [String]) {
      self.requestedKillswitches = requestedKillswitches
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(requestedKillswitches, forKey: .requestedKillswitches)
    }
  }
}

extension AppAPIClient.Killswitch.GetKillSwitches {
  public enum ResponseValue: Codable, Hashable, Sendable {
    case boolean(Bool)
    case number(Int)

    public var boolean: Bool? {
      guard case let .boolean(value) = self else {
        return nil
      }
      return value
    }

    public var number: Int? {
      guard case let .number(value) = self else {
        return nil
      }
      return value
    }

    public init(from decoder: Decoder) throws {
      do {
        self = .boolean(try .init(from: decoder))
        return
      } catch {
      }
      do {
        self = .number(try .init(from: decoder))
        return
      } catch {
      }
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "No enum case can be decoded")
      throw DecodingError.typeMismatch(Self.self, context)
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      switch self {
      case .boolean(let value):
        try container.encode(value)
      case .number(let value):
        try container.encode(value)
      }
    }
  }
  public typealias Response = [String: ResponseValue]
}
