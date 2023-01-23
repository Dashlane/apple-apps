import Foundation

public enum SSOAccountError: Error {
    case userNotFound(_ ssoToken: String, _ serviceProviderKey: String)
    case userDataNotFetched
    case invalidServiceProviderKey
    case failedLoginOnSSOPage
}
