import Foundation

extension URL {
    private func iterateBackupThroughFolder() throws {
        let directoryEnum = try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil)
        for file in directoryEnum {
            var fileURL: URL = file
            try fileURL.setExcludedFromiCloudBackup()
            let isDir = (try fileURL.resourceValues(forKeys: [.isDirectoryKey])).isDirectory ?? false
            if isDir {
                try fileURL.iterateBackupThroughFolder()
            }
        }
    }

    public mutating func setExcludedFromiCloudBackup() throws {
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try self.setResourceValues(values)
        let isDir = (try self.resourceValues(forKeys: [.isDirectoryKey])).isDirectory ?? false
        if isDir {
            try self.iterateBackupThroughFolder()
        }
    }
}
