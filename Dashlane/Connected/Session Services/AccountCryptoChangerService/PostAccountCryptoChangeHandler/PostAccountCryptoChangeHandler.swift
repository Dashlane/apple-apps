import Foundation
import CoreSession
import CorePersonalData
import DashTypes

protocol PostAccountCryptoChangeHandler {
    func handle(_ session: Session, syncTimestamp: Timestamp) throws
}
