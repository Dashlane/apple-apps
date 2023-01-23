import Foundation
import CorePersonalData

public protocol CopiablePersonalData {
        var valueToCopy: String { get }
    var fieldToCopy: DetailFieldType { get }
}

extension CopiablePersonalData {
    static var requireSecureCopy: Bool {
        return false
    }
}
