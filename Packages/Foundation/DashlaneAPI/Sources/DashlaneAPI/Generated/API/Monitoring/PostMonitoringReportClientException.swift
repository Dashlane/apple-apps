import Foundation

extension UnsignedAPIClient.Monitoring {
  public struct ReportClientException: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/monitoring/ReportClientException"

    public let api: UnsignedAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      action: String, message: String, additionalInfo: String? = nil, code: Int? = nil,
      exceptionType: String? = nil, featureFlips: [String]? = nil, file: String? = nil,
      functionName: String? = nil, initialUseCaseModule: String? = nil,
      initialUseCaseName: String? = nil, initialUseCaseStacktrace: String? = nil,
      stack: String? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        action: action, message: message, additionalInfo: additionalInfo, code: code,
        exceptionType: exceptionType, featureFlips: featureFlips, file: file,
        functionName: functionName, initialUseCaseModule: initialUseCaseModule,
        initialUseCaseName: initialUseCaseName, initialUseCaseStacktrace: initialUseCaseStacktrace,
        stack: stack)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var reportClientException: ReportClientException {
    ReportClientException(api: api)
  }
}

extension UnsignedAPIClient.Monitoring.ReportClientException {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case action = "action"
      case message = "message"
      case additionalInfo = "additionalInfo"
      case code = "code"
      case exceptionType = "exceptionType"
      case featureFlips = "featureFlips"
      case file = "file"
      case functionName = "functionName"
      case initialUseCaseModule = "initialUseCaseModule"
      case initialUseCaseName = "initialUseCaseName"
      case initialUseCaseStacktrace = "initialUseCaseStacktrace"
      case stack = "stack"
    }

    public let action: String
    public let message: String
    public let additionalInfo: String?
    public let code: Int?
    public let exceptionType: String?
    public let featureFlips: [String]?
    public let file: String?
    public let functionName: String?
    public let initialUseCaseModule: String?
    public let initialUseCaseName: String?
    public let initialUseCaseStacktrace: String?
    public let stack: String?

    public init(
      action: String, message: String, additionalInfo: String? = nil, code: Int? = nil,
      exceptionType: String? = nil, featureFlips: [String]? = nil, file: String? = nil,
      functionName: String? = nil, initialUseCaseModule: String? = nil,
      initialUseCaseName: String? = nil, initialUseCaseStacktrace: String? = nil,
      stack: String? = nil
    ) {
      self.action = action
      self.message = message
      self.additionalInfo = additionalInfo
      self.code = code
      self.exceptionType = exceptionType
      self.featureFlips = featureFlips
      self.file = file
      self.functionName = functionName
      self.initialUseCaseModule = initialUseCaseModule
      self.initialUseCaseName = initialUseCaseName
      self.initialUseCaseStacktrace = initialUseCaseStacktrace
      self.stack = stack
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(action, forKey: .action)
      try container.encode(message, forKey: .message)
      try container.encodeIfPresent(additionalInfo, forKey: .additionalInfo)
      try container.encodeIfPresent(code, forKey: .code)
      try container.encodeIfPresent(exceptionType, forKey: .exceptionType)
      try container.encodeIfPresent(featureFlips, forKey: .featureFlips)
      try container.encodeIfPresent(file, forKey: .file)
      try container.encodeIfPresent(functionName, forKey: .functionName)
      try container.encodeIfPresent(initialUseCaseModule, forKey: .initialUseCaseModule)
      try container.encodeIfPresent(initialUseCaseName, forKey: .initialUseCaseName)
      try container.encodeIfPresent(initialUseCaseStacktrace, forKey: .initialUseCaseStacktrace)
      try container.encodeIfPresent(stack, forKey: .stack)
    }
  }
}

extension UnsignedAPIClient.Monitoring.ReportClientException {
  public typealias Response = Empty?
}
