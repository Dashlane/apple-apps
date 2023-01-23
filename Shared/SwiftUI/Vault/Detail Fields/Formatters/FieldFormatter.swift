import Foundation

class FieldFormatter: Formatter {
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        guard let obj = obj else {
            return false
        }

        obj.pointee = string as NSString

        return true
    }
}
