import Foundation

public protocol UTF16EncoderDelegate {

    func encode(_ password: String) -> [CChar]

}
