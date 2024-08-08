import Foundation

extension URL {
  public static func temporary() throws -> URL {
    let directory = NSTemporaryDirectory()
    let name = UUID().uuidString
    let directoryURL = URL(fileURLWithPath: directory).appendingPathComponent(name)
    try FileManager.default.createDirectory(
      at: directoryURL,
      withIntermediateDirectories: false,
      attributes: [.protectionKey: FileProtectionType.none])

    return try createEmptyTemporaryDirectory().appendingPathComponent("temp")
  }

  public static func createEmptyTemporaryDirectory() throws -> URL {
    let directory = NSTemporaryDirectory()
    let name = UUID().uuidString
    let directoryURL = URL(fileURLWithPath: directory).appendingPathComponent(name)
    try FileManager.default.createDirectory(
      at: directoryURL,
      withIntermediateDirectories: false,
      attributes: [.protectionKey: FileProtectionType.none])

    return directoryURL
  }
}
