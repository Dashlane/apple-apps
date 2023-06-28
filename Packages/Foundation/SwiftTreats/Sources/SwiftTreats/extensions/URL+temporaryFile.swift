import Foundation

extension URL {
                public static func temporaryFile() -> URL {
        let directory = NSTemporaryDirectory()
        let name = UUID().uuidString
        let directoryURL = URL(fileURLWithPath: directory).appendingPathComponent(name)
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: false)
        return directoryURL.appendingPathComponent("temp")
    }
}
