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
    
    init(context: PluginContext, target: Target) throws {
                        let availablePaths = ["/opt/homebrew/bin/sourcery",
                              "/usr/local/bin/sourcery"]
        guard let path = availablePaths.first(where: { FileManager.default.fileExists(atPath: $0) }) else {
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
