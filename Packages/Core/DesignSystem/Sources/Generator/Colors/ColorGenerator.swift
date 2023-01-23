import Foundation

@available(macOS 12.0, *)
struct ColorGenerator {
    
    let destination: URL
    let apiToken: String
    
                func generate() async throws {
        print("⏳ Fetching colors from Specify...")
        let lightModeColors = try await fetchColors(for: .light)
        let darkModeColors = try await fetchColors(for: .dark)
        
        print("⏳ Merging light mode and dark mode colors into color pairs...")
        let colorAssets = try lightModeColors.paired(with: darkModeColors)
        
        print("⏳ Generating an asset catalogue...")
        try generateAssetCatalogue(with: colorAssets)
        
        print("⏳ Adding a flag for including the color location into its name...")
        try includeFoldersToColorNames()

        print("✅ Color assets catalogue generated")
    }
    
        private func fetchColors(for userInterfaceStyle: UserInterfaceStyle) async throws -> [SpecifyColor] {
        let request = URLRequest.makeSpecifyRequest(
            endpoint: .colorTokens(userInterfaceStyle),
            apiToken: apiToken
        )
        let (data, _) = try await URLSession.shared.data(for: request)
        let colors = try JSONDecoder().decode([SpecifyColor].self, from: data)
        return colors
    }
    
                    private func generateAssetCatalogue(with colors: [ColorAsset]) throws {
        let assetCatalogueURL = destination.appendingPathComponent("Resources/Assets.xcassets", isDirectory: true)
        let encoder = JSONEncoder.sortedPrettyPrinted
        
        for color in colors {
            let directory = assetCatalogueURL.appendingPathComponent(
                "Colors/\(color.nameComponents.joined(separator: "/")).colorset",
                isDirectory: false
            )
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            try encoder.encode(color).write(to: directory.appendingPathComponent("Contents.json"))
        }
    }
    
                        private func includeFoldersToColorNames() throws {
        let colorsAssetPath = destination.appendingPathComponent("Resources/Assets.xcassets/Colors", isDirectory: true)
        let subPaths = try FileManager.default.subpathsOfDirectory(atPath: colorsAssetPath.relativePath)
        let encoder = JSONEncoder.sortedPrettyPrinted
        for subPath in subPaths {
            guard !subPath.hasSuffix(".colorset") && !subPath.hasSuffix(".json") && !subPath.hasPrefix(".")
            else { continue }
            let pathComponent = "Resources/Assets.xcassets/Colors/\(subPath)/Contents.json"
            let filePath = destination.appendingPathComponent(pathComponent, isDirectory: false)
            try encoder.encode(NamespaceMetadata()).write(to: filePath)
        }
    }
}

private extension Dictionary where Key == String, Value == RGBAValue {
                func merged(with darkColorDictionary: [String: RGBAValue]) throws -> [String: (light: RGBAValue, dark: RGBAValue)] {
        guard Set(keys) == Set(darkColorDictionary.keys) else {
            let differences = self.differences(darkColorDictionary)
            throw ColorGeneratorError.darkAndLightPalettesNotIdentical(differences: differences)
        }
        
        var dict = [String: (light: RGBAValue, dark: RGBAValue)]()
        for (colorName, lightModeValue) in self {
            guard let darkModeValue = darkColorDictionary[colorName] else {
                throw ColorGeneratorError.darkAndLightPalettesNotIdentical()
            }
            dict[colorName] = (light: lightModeValue, dark: darkModeValue)
        }
        
        return dict
    }

    func differences(_ dictionary: Dictionary) -> Set<Dictionary.Key> {
        return Set(keys).symmetricDifference(Set(dictionary.keys))
    }
}

private extension URL {
    var subfolders: [URL] {
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])) ?? [URL]()
    }
}

private extension Array where Element == SpecifyColor {
    func dictionary() -> [String: RGBAValue] {
        return self.reduce(into: [String: RGBAValue]()) { partialResult, color in
            partialResult[color.name] = color.rgbaValue
        }
    }
    
                func paired(with darkModeColors: [SpecifyColor]) throws -> [ColorAsset] {
        let lightColorsDict = self.dictionary()
        let darkColorsDict = darkModeColors.dictionary()
        
        let mergedDict = try lightColorsDict.merged(with: darkColorsDict)
        
        let colorAssets = mergedDict.map { colorName, colorValues -> ColorAsset in
            let nameComponents = colorName.split(separator: "/").map(String.init)
            let normalizedName = nameComponents.first! + nameComponents.dropFirst().map(\.capitalized).joined()
            
            return ColorAsset(
                name: String(normalizedName),
                nameComponents: nameComponents,
                lightModeValue: colorValues.light,
                darkModeValue: colorValues.dark
            )
        }
        
        return colorAssets
    }
}
