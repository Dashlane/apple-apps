import Foundation
import PasswordFormatterForKWC3

extension KWC3 {
        static func encodePassword(_ password: String) -> [CChar] {
        let passwordBytes = [CChar](password.utf8CString)
        var passwordBytesLength = Int32(passwordBytes.count)
        let result = doTheMagic(passwordBytes, &passwordBytesLength)
        let buffer = UnsafeBufferPointer(start: result, count: Int(passwordBytesLength) - 1)
        return [CChar](buffer)
    }
}
