import Foundation

extension UserDeviceAPIClient.Account {
  public struct ChangeAccountType: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/account/ChangeAccountType"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      newAccountType: AccountType, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(newAccountType: newAccountType)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var changeAccountType: ChangeAccountType {
    ChangeAccountType(api: api)
  }
}

extension UserDeviceAPIClient.Account.ChangeAccountType {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case newAccountType = "newAccountType"
    }

    public let newAccountType: AccountType

    public init(newAccountType: AccountType) {
      self.newAccountType = newAccountType
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(newAccountType, forKey: .newAccountType)
    }
  }
}

extension UserDeviceAPIClient.Account.ChangeAccountType {
  public typealias Response = Empty?
}
