import CorePersonalData
import CoreSession
import DashTypes
import Foundation

protocol PostAccountCryptoChangeHandler {
  func handle(_ session: Session, syncTimestamp: Timestamp) throws
}
