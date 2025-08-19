import CorePersonalData
import CoreSession
import CoreTypes
import Foundation

protocol PostAccountCryptoChangeHandler {
  func handle(_ session: Session, syncTimestamp: Timestamp) throws
}
