import Foundation
import DashTypes

public enum FileUploadServiceError: Error {
    case uploadFailed
}

public struct FileUploadService {
    
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
    
    private let uploadAuthentication: UploadAuthentication
    private let webservice: ProgressableNetworkingEngine

    public init(authentication: UploadAuthentication, webservice: ProgressableNetworkingEngine) {
        self.uploadAuthentication = authentication
        self.webservice = webservice
    }
    
                                @discardableResult public func upload(file: URL, progress: inout Progress?, completion: @escaping (Result<Bool, Swift.Error>) -> Void) throws -> URLSessionTask {
        
        let fileContent = try Data(contentsOf: file)
        
        let keyOrder = [Key.bucket.rawValue,
                        Key.policy.rawValue,
                        Key.date.rawValue,
                        Key.algorithm.rawValue,
                        Key.signature.rawValue,
                        Key.securityToken.rawValue,
                        Key.credential.rawValue,
                        Key.accessControlLevel.rawValue,
                        Key.key.rawValue,
                        Key.file.rawValue]

        let params: [String: Encodable] = [
            Key.key.rawValue: uploadAuthentication.key,
            Key.bucket.rawValue: uploadAuthentication.fields.bucket,
            Key.algorithm.rawValue: uploadAuthentication.fields.algorithm,
            Key.credential.rawValue: uploadAuthentication.fields.credential,
            Key.securityToken.rawValue: uploadAuthentication.fields.securityToken,
            Key.date.rawValue: uploadAuthentication.fields.date,
            Key.policy.rawValue: uploadAuthentication.fields.policy,
            Key.signature.rawValue: uploadAuthentication.fields.signature,
            Key.accessControlLevel.rawValue: uploadAuthentication.accessControlLevel
        ]

        let resource = Resource(endpoint: uploadAuthentication.url.absoluteString,
                                method: .post,
                                params: params,
                                contentFormat: .multipart,
                                needsAuthentication: false,
                                file: File(key: Key.file.rawValue, filename: file.lastPathComponent, data: fileContent),
                                keyOrder: keyOrder,
                                parser: FileUploadServiceParser())

        let task = resource.load(on: webservice, completion: completion)
        progress = task.progress
        return task
    }
}

struct FileUploadServiceParser: ResponseParserProtocol {

    func parse(data: Data) throws -> Bool {
        guard data.isEmpty else {
            throw FileUploadServiceError.uploadFailed
        }
        return true
    }
}
