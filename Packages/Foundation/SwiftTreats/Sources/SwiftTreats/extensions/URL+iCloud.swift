import Foundation

extension URL {
    private func iterateBackupThroughFolder() throws {
        let directoryEnum = try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: [.isDirectoryKey, .isExcludedFromBackupKey])
        for file in directoryEnum {
            var fileURL: URL = file

            let values = try fileURL.resourceValues(forKeys: [.isDirectoryKey, .isExcludedFromBackupKey])

            if values.isExcludedFromBackup == false {
                try fileURL.setExcludedFromiCloudBackup()
            }

            let isDir = values.isDirectory ?? false
            if isDir {
                try fileURL.iterateBackupThroughFolder()
            }
        }
    }

    public mutating func setExcludedFromiCloudBackup() throws {
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try self.setResourceValues(values)
    }
}
