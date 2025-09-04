import Foundation
import LogFoundation

@Loggable
enum SettingsError: Error {
  case settingsAlreadyExistsFor(directoryURL: URL)
  case fileSystemErrorAt(path: String)
}
