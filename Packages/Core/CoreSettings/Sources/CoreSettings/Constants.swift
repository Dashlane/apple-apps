import Foundation

enum SettingsError: Error {
  case settingsAlreadyExistsFor(directoryURL: URL)
  case fileSystemErrorAt(path: String)
}
