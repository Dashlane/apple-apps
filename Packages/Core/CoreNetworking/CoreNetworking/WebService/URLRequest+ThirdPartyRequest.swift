import Foundation

public extension URLRequest {
    static func build(from url: URL,
                      params: [String: ParameterValue],
                      contentFormat: Request.ContentFormat,
                      postData: Data? = nil,
                      keyOrder: [String] = [],
                      multipartBoundary: String) -> URLRequest {
        return Request(request: .init(url: url),
                       params: params,
                       needsAuthentication: false,
                       contentFormat: .multipart,
                       postData: nil,
                       keyOrder: keyOrder,
                       multipartBoundary: UUID().uuidString)
        .urlRequest
    }
}
