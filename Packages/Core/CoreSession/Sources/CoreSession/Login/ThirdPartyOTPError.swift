import Foundation
import LogFoundation

@Loggable
public enum ThirdPartyOTPError: Error {
  case wrongOTP
  case invalidServerBackupResponse
  case duoPushNotEnabled
  case duoChallengeFailed
}
