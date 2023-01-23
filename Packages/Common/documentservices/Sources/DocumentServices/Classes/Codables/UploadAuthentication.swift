import Foundation

public struct UploadAuthentication: Codable {
    
    struct Fields: Codable {
        let bucket: String
        let policy: String
        let algorithm: String
        let credential: String
        let date: String
        let securityToken: String
        let signature: String
        
        private enum CodingKeys : String, CodingKey {
            case policy = "Policy"
            case bucket
            case algorithm = "X-Amz-Algorithm"
            case credential = "X-Amz-Credential"
            case date = "X-Amz-Date"
            case securityToken = "X-Amz-Security-Token"
            case signature = "X-Amz-Signature"
        }
    }
    
    let accessControlLevel: String
    let fields: Fields
    public let key: String
    let quota: Quota.QuotaValues
    let url: URL
    
    private enum CodingKeys : String, CodingKey {
        case accessControlLevel = "acl"
        case fields
        case key
        case quota
        case url
    }
}
