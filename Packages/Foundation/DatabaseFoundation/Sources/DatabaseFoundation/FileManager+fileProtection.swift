import Foundation

extension FileManager {
  public func clearFileProtection(in directory: URL) throws {
    let contents =
      try contentsOfDirectory(
        at: directory, includingPropertiesForKeys: [.fileProtectionKey], options: .skipsHiddenFiles)
      + [directory]

    let acceptedProtections: Set<URLFileProtection> = [
      .completeUntilFirstUserAuthentication, URLFileProtection.none,
    ]

    for url in contents {
      guard
        let fileProtection = try? url.resourceValues(forKeys: [.fileProtectionKey]).fileProtection,
        !acceptedProtections.contains(fileProtection)
      else {
        continue
      }

      try setAttributes([.protectionKey: FileProtectionType.none], ofItemAtPath: url.path)
    }
  }
}
