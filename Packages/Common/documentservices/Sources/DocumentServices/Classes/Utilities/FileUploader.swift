import Combine
import DashlaneAPI
import Foundation
import SwiftTreats

class FileUploader: NSObject, URLSessionTaskDelegate {

  private enum Key: String {
    case key
    case bucket
    case algorithm = "X-Amz-Algorithm"
    case credential = "X-Amz-Credential"
    case date = "X-Amz-Date"
    case policy = "Policy"
    case signature = "X-Amz-Signature"
    case accessControlLevel = "acl"
    case file
    case securityToken = "X-Amz-Security-Token"
  }

  private var progress: Progress?

  func uploadFile(
    at fileURL: URL,
    with uploadAuthentication: UserDeviceAPIClient.Securefile.GetUploadLink.Response,
    progress: Progress
  ) async throws {
    self.progress = progress

    guard let url = URL(string: uploadAuthentication.url) else {
      throw URLError(.badURL)
    }

    var requestBuilder = MultipartURLRequestBuilder(url: url)

    requestBuilder[form: Key.key.rawValue] = uploadAuthentication.key
    requestBuilder[form: Key.bucket.rawValue] =
      uploadAuthentication.fields[Key.bucket.rawValue] ?? ""
    requestBuilder[form: Key.algorithm.rawValue] =
      uploadAuthentication.fields[Key.algorithm.rawValue] ?? ""
    requestBuilder[form: Key.credential.rawValue] =
      uploadAuthentication.fields[Key.credential.rawValue] ?? ""
    requestBuilder[form: Key.securityToken.rawValue] =
      uploadAuthentication.fields[Key.securityToken.rawValue] ?? ""
    requestBuilder[form: Key.date.rawValue] = uploadAuthentication.fields[Key.date.rawValue] ?? ""
    requestBuilder[form: Key.policy.rawValue] =
      uploadAuthentication.fields[Key.policy.rawValue] ?? ""
    requestBuilder[form: Key.signature.rawValue] =
      uploadAuthentication.fields[Key.signature.rawValue] ?? ""
    requestBuilder[form: Key.accessControlLevel.rawValue] = uploadAuthentication.acl

    let fileContent = try Data(contentsOf: fileURL)
    requestBuilder[file: fileURL.lastPathComponent] = fileContent

    let urlRequest = requestBuilder.makeURLRequest()

    let (_, response) = try await URLSession.shared.data(for: urlRequest, delegate: self)
    guard let urlResponse = response as? HTTPURLResponse,
      urlResponse.statusCode >= 200 && urlResponse.statusCode <= 299
    else {
      throw URLError(.badServerResponse)
    }
  }

  func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
    self.progress?.addChild(task.progress, withPendingUnitCount: 1)
  }
}
