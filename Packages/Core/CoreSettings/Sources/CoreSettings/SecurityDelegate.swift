import Foundation

public protocol SecurityDelegate: AnyObject {

    func encrypt(data: Data) -> Data?
    func decrypt(data: Data) -> Data?

}
