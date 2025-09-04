import Foundation
import LogFoundation

@Loggable
public enum SharingDeactivationReason: Error {
  case b2bSharingDisabled
  case frozenAccount
}
