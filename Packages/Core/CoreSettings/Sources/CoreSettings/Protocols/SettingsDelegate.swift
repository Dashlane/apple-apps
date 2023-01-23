import Foundation

public protocol SettingsDelegate: AnyObject {

    func encrypt(data: Data) -> Data?
    func decrypt(data: Data) -> Data?

}
