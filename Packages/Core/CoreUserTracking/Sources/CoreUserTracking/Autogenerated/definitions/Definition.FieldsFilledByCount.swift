import Foundation

extension Definition {

public struct `FieldsFilledByCount`: Encodable {
public init(`autofillCount`: Int, `autologinCount`: Int, `manuallyTypedCount`: Int) {
self.autofillCount = autofillCount
self.autologinCount = autologinCount
self.manuallyTypedCount = manuallyTypedCount
}
public let autofillCount: Int
public let autologinCount: Int
public let manuallyTypedCount: Int
}
}