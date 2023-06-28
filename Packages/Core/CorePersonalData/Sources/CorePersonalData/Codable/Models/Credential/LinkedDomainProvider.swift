import Foundation

public protocol LinkedDomainProvider {
    subscript(domain: String) -> [String]? { get }
}
