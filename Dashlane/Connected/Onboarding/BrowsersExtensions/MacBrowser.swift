import Foundation
import CoreSession

enum MacBrowser: String, Hashable, CaseIterable {
    case safari = "com.apple.Safari"
    case safariTechPreview = "com.apple.SafariTechnologyPreview"
    case firefox = "org.mozilla.firefox"
    case chrome = "com.google.Chrome"
    case edge = "com.microsoft.edgemac"

    init(name: String?) {
        guard let name = name else {
            self = .chrome
            return
        }
        switch name {
        case "Safari":
            self = .safari
        case "Safari Technology Preview":
            self = .safariTechPreview
        case "Firefox":
            self = .firefox
        case "Google Chrome":
            self = .chrome
        case "Microsoft Edge":
            self = .edge
        default:
            self = .chrome
        }
    }

    var title: String {
        switch self {
        case .safari: return "Safari"
        case .safariTechPreview: return "Safari Technology Preview"
        case .chrome: return "Chrome"
        case .firefox: return "Firefox"
        case .edge: return "Edge"
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

extension MacBrowser {
    func artwork(isLegacyInstalled: Bool = false) -> ImageAsset {
        switch self {
        case .chrome:
           return FiberAsset.browserChrome
        case .edge:
            return FiberAsset.browserEdge
        case .firefox:
            return FiberAsset.browserFirefox
		case .safari, .safariTechPreview:
            if isLegacyInstalled {
                return FiberAsset.browserSafariLegacy
            } else {
                return FiberAsset.browserSafari
            }
        }
    }
}

extension MacBrowser {

    func isBrowserExtensionInstalled(sessionDirectory: SessionDirectory) -> Bool {
        switch self {
        case .chrome:
            let chromeFolder = URL(fileURLWithPath: "\(FileManager.homeDirectoryPath)/Library/Application Support/Google/Chrome/Default/Extensions",
                                   isDirectory: true)
            return chromeExtensionIdentifiers.installedChromiumExtension(inFolder: chromeFolder) != nil
        case .firefox:
            return isFirefoxExtensionInstalled()
        case .edge:
            let edgeFolder = URL(fileURLWithPath: "\(FileManager.homeDirectoryPath)/Library/Application Support/Microsoft Edge/Default/Extensions",
                                 isDirectory: true)
            return edgeExtensionIdentifiers.installedChromiumExtension(inFolder: edgeFolder) != nil
        case .safari, .safariTechPreview:
            guard let safariURL = try? sessionDirectory.storeURL(for: .galactica, in: .safari) else { return false }
            var isDirectory: ObjCBool = false
            return FileManager.default.fileExists(atPath: safariURL.path, isDirectory: &isDirectory)
        }
    }

    private func isFirefoxExtensionInstalled() -> Bool {
        let profilesURL = URL(fileURLWithPath: "\(FileManager.homeDirectoryPath)/Library/Application Support/Firefox/Profiles",
                              isDirectory: true)
        guard let profiles = try? FileManager.default.contentsOfDirectory(at: profilesURL, includingPropertiesForKeys: nil) else {
            return false
        }
        for profile in profiles {
            let extensionsFileURL = profile.appendingPathComponent("extensions.json")
            guard let json = try? Data(contentsOf: extensionsFileURL), let jsonString = String(data: json, encoding: .utf8) else {
                continue
            }
            if jsonString.contains("_") {
                return true
            }
        }
        return false
    }
}

private extension MacBrowser {
    var chromeExtensionIdentifiers: [String] {
        [
            "fdjamakpfbbddfjaooikfcpapjohcfmg", 
            "pbenjapkjdkdlfdjjokeendimjkgjgjb" 
        ]
    }

    var edgeExtensionIdentifiers: [String] {
        [
            "gehmmocbbkpblljhkekmfhjpfbkclbph" 
        ]
    }
}

private extension FileManager {
    static var homeDirectoryPath: String {
        NSHomeDirectory().appending("/../../../../")
    }
}

private extension Array where Element == String {
    func installedChromiumExtension(inFolder folder: URL) -> String? {
        let manager = FileManager.default
        return first(where: {
            var isDirectory: ObjCBool = false
            let localDirectory = folder.appendingPathComponent($0, isDirectory: true)
            return manager.fileExists(atPath: localDirectory.path, isDirectory: &isDirectory)
        })
    }
}
