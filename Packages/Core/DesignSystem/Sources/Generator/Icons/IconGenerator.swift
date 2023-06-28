import Foundation

@available(macOS 12.0, *)
struct IconGenerator {
    let destination: URL
    let apiToken: String

    func generate() async throws {
        print("⏳ Fetching icons from Specify...")
        let request = URLRequest.makeSpecifyRequest(endpoint: .iconTokens, apiToken: apiToken)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decodedIcons = try JSONDecoder().decode([SpecifyIcon].self, from: data).filter(\.shouldBeProcessed)
        print("✅ Fetched \(decodedIcons.count) icons from Specify.")

        print("⏳ Fetching individual image data for \(decodedIcons.count) icons...")
        let icons = try await withThrowingTaskGroup(of: SpecifyIcon.self) { group -> [SpecifyIcon] in
            for icon in decodedIcons {
                group.addTask {
                    return try await icon.withImage()
                }
            }
            var icons = [SpecifyIcon]()
            for try await icon in group {
                icons.append(icon)
            }
            return icons
        }
        print("✅ Fetched individual image data:")
        try deleteIconsAssetCatalogue()
        print("⏳ Generating icons asset catalogue...")
        try generateAssetCatalogue(for: icons)
        print("✅ Generated icons asset catalogue.")
    }

    private func deleteIconsAssetCatalogue() throws {
        let iconsDirectory = destination.appendingPathComponent("Resources/Assets.xcassets/Icons/", isDirectory: true)
        if FileManager.default.fileExists(atPath: iconsDirectory.path) {
            try FileManager.default.removeItem(at: iconsDirectory)
            print("🗑 Deleted previous icons asset catalogue.")
        }
    }

    private func generateAssetCatalogue(for icons: [SpecifyIcon]) throws {
        let assetCatalogueURL = destination.appendingPathComponent("Resources/Assets.xcassets", isDirectory: true)
        let encoder = JSONEncoder.sortedPrettyPrinted
        var paths = Set<String>()

        for icon in icons {
            let iconName = icon.nameComponents.last!
            let subdirectoriesPath = icon.nameComponents.dropLast().joined(separator: "/")
            let path = "Icons/\(subdirectoriesPath)/\(iconName).imageset"
            let completeDirectory = assetCatalogueURL.appendingPathComponent(path)

            paths.insert(subdirectoriesPath)

                        try FileManager.default.createDirectory(at: completeDirectory, withIntermediateDirectories: true, attributes: nil)

                        try icon.image?.write(to: completeDirectory.appendingPathComponent("/\(iconName).svg"))
                        let iconMetadata = IconMetadata(filename: "\(iconName).svg")
            let iconMetadataFileURL = completeDirectory.appendingPathComponent("Contents.json")
            try encoder.encode(iconMetadata).write(to: iconMetadataFileURL)
        }

                for subdirectoryPath in paths {
            var pathComponents = subdirectoryPath.components(separatedBy: "/")
            while !pathComponents.isEmpty {
                let pathComponent = pathComponents.joined(separator: "/")
                let subdirectory = assetCatalogueURL.appendingPathComponent("Icons/\(pathComponent)", isDirectory: true)
                let fileURL = subdirectory.appendingPathComponent("Contents.json", isDirectory: false)
                try encoder.encode(NamespaceMetadata()).write(to: fileURL)
                pathComponents.removeLast()
            }
        }
    }
}
