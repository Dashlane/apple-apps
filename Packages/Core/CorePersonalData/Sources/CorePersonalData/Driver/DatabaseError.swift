import Foundation
import LogFoundation

@Loggable
public enum DatabaseError: Error {
  case cannotSaveTemporaryRecord
}
