import Foundation
import PackagePlugin

@main
struct SourceryPlugin: CommandPlugin {

    func performCommand(context: PluginContext, arguments: [String]) async throws {
        print("Package directory is \(context.package.directory)")
        let resourceFile = "sourcery.yml"
        let targets = context.package.targets.compactMap { $0 as? SourceModuleTarget }
        for target in targets {
            print("Target directory is \(target.directory)")
            let yamlPath = target.directory
                .appending(subpath: "Resources/")
                .appending(resourceFile)
            print("Looking for configuration at \(yamlPath.string)")
            if FileManager.default.fileExists(atPath: yamlPath.string) {
                print("Found configuration at \(yamlPath.string)")
                let configuration = try SourceryCommandConfiguration(context: context, target: target)
                try run(tool: configuration.toolPath, arguments: ["--config", yamlPath.string, "--verbose"], environment: configuration.environment)
            } else {
                print("Didn't find configuration file at \(yamlPath.string)")
            }
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SourceryPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        print("Launching SourceryPlugin on \(context.xcodeProject.directory)")
                for target in context.xcodeProject.targets.filter({ Set(arguments).contains($0.displayName) }) {
            guard let yaml = self.yamlPath(of: target, from: context.xcodeProject.directory) else {
                print("Sourcery configuration was not found for \(target.displayName). Skipping")
                continue
            }
            print("Sourcery configuration found for \(target.displayName)")
            let configuration = try SourceryCommandConfiguration(yaml: yaml, context: context, target: target)
            try run(tool: configuration.toolPath, arguments: ["--config", yaml.string, "--verbose", "--disableCache"], environment: configuration.environment)
        }
    }

    func yamlPath(of target: XcodeTarget, from base: PackagePlugin.Path) -> Path? {
        for filename in ["sourcery.yml", ".sourcery.yml"] {
            let yamlPath = base
                .appending(subpath: target.displayName)
                .appending(filename)
            if FileManager.default.fileExists(atPath: yamlPath.string) {
                return yamlPath
            }
        }
        return nil
    }
}
#endif

protocol PluginWorkDirectoryProvider {
    var pluginWorkDirectory: PackagePlugin.Path { get }
}

extension PluginContext: PluginWorkDirectoryProvider {}
extension XcodePluginContext: PluginWorkDirectoryProvider {}

extension XcodeTarget {
    func targetPath(base: Path) -> Path {
        return base.appending(subpath: displayName)
    }
}

enum InstallError: Error, CustomDebugStringConvertible {
    case missingSourcery

    var debugDescription: String {
        switch self {
        case .missingSourcery:
            return "It looks like Sourcery is not installed on this machine. Please install it using Brew."
        }
    }

}

private struct SourceryCommandConfiguration {
    let toolPath: Path
    let inputFilesPath: Path
    let outputFilesPath: Path
    let cachePath: Path
    let configPath: Path
    let environment: [String: String]

    static var toolPath: String? {
                        let availablePaths = ["/opt/homebrew/bin/sourcery",
                              "/usr/local/bin/sourcery"]
        guard let path = availablePaths.first(where: { FileManager.default.fileExists(atPath: $0) }) else {
            return nil
        }
        return path
    }

    init(context: PluginContext, target: Target) throws {
        guard let path = Self.toolPath else {
            throw InstallError.missingSourcery
        }
        let resourcesFolder = target.directory.appending("Resources")
        let configFile = resourcesFolder.appending("sourcery.yml")
        self.toolPath = Path(path)
        self.inputFilesPath = target.directory
        self.configPath = configFile
        self.outputFilesPath = target.directory.appending("Generated")
        self.cachePath = context.pluginWorkDirectory.appending("Cache")
        self.environment = [
            "INPUT_DIR": inputFilesPath.string,
            "OUTPUT_DIR": outputFilesPath.string,
            "CACHE_DIR": cachePath.string
        ]
    }

    init(yaml: Path, context: XcodePluginContext, target: XcodeTarget) throws {
        guard let path = Self.toolPath else {
            throw InstallError.missingSourcery
        }
        self.toolPath = Path(path)
        let targetPath = target.targetPath(base: context.xcodeProject.directory)
        self.inputFilesPath = targetPath
        self.configPath = yaml
        self.outputFilesPath = targetPath.appending("Generated")
        self.cachePath = context.pluginWorkDirectory.appending("Cache")
        self.environment = [
            "INPUT_DIR": inputFilesPath.string,
            "OUTPUT_DIR": outputFilesPath.string,
            "CACHE_DIR": cachePath.string
        ]
    }
}

func run(tool: Path, arguments: [String], environment: [String: String]) throws {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: tool.string)
    task.arguments = arguments
    task.environment = environment

    print("""
    Executing task:
    - \(tool.string)
    - \(arguments)
    - \(environment)
    """)

    try task.run()
    task.waitUntilExit()

    if task.terminationReason != .exit || task.terminationStatus != 0 {
        let problem = "\(task.terminationReason):\(task.terminationStatus)"
        Diagnostics.error("\(tool) invocation failed: \(problem)")
    }
}
