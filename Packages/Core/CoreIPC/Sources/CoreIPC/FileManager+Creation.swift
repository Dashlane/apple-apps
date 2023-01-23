import Foundation

extension FileManager {
    func createDirectoryIfNotExisting(at url: URL) throws {
        var isDirectory: ObjCBool = true
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
