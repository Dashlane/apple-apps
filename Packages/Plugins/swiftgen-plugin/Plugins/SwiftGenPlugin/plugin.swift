import Foundation
import PackagePlugin

@main
struct SwiftGenPlugin: CommandPlugin {

    func performCommand(context: PluginContext, arguments: [String]) async throws {
        print("Package directory is \(context.package.directory)")
        let resourceFile = "swiftgen.yml"
        let targets = context.package.targets.compactMap { $0 as? SourceModuleTarget }
        for target in targets {
            print("Target directory is \(target.directory)")
            let yamlPath = target.directory
                .appending(subpath: "Resources/")
                .appending(resourceFile)
            print("Looking for configuration at \(yamlPath.string)")
            if FileManager.default.fileExists(atPath: yamlPath.string) {
                print("Found configuration at \(yamlPath.string)")
                let configuration = try SwiftGenCommandConfiguration(context: context, target: target)

                                try? FileManager.default.createDirectory(
                    atPath: configuration.outputFilesPath.string,
                    withIntermediateDirectories: true
                )

                try run(tool: configuration.toolPath, arguments: ["config", "run", "--verbose", "--config", yamlPath.string], environment: configuration.environment)
            } else {
                print("Didn't find configuration file at \(yamlPath.string)")
            }
        }
    }
}

enum InstallError: Error, CustomDebugStringConvertible {
    case missingSwiftgen

    var debugDescription: String {
        switch self {
        case .missingSwiftgen:
            return "It looks like SwiftGen is not installed on this machine. Please install it using Brew."
        }
    }

}

private struct SwiftGenCommandConfiguration {
    let toolPath: Path
    let configPath: Path
    let inputFilesPath: Path
    let outputFilesPath: Path
    let environment: [String: String]

    init(context: PluginContext, target: Target) throws {
                                        let availablePaths = ["/opt/homebrew/bin/swiftgen",
                              "/usr/local/bin/swiftgen"]
        guard let path = availablePaths.first(where: { FileManager.default.fileExists(atPath: $0) }) else {
            throw InstallError.missingSwiftgen
        }

        let resourcesFolder = target.directory.appending("Resources")
        let configFile = resourcesFolder.appending("swiftgen.yml")
        self.toolPath = Path(path)
        self.configPath = configFile
        self.inputFilesPath = resourcesFolder
        self.outputFilesPath = target.directory.appending("Generated")
        self.environment = [
            "INPUT_DIR": resourcesFolder.string,
            "OUTPUT_DIR": outputFilesPath.string
        ]
    }
}


private extension Command {
    static func swiftgenCommand(for swiftgen: SwiftGenCommandConfiguration) -> Command {

        let inputFiles = try! FileManager.default.contentsOfDirectory(atPath: swiftgen.inputFilesPath.string).map(Path.init)
        let outputFiles = try! FileManager.default.contentsOfDirectory(atPath: swiftgen.outputFilesPath.string).map(Path.init)

        print("Input files \(inputFiles)")
        print("Output files \(outputFiles)")

        return .prebuildCommand(
            displayName: "Running SwiftGen",
            executable: swiftgen.toolPath,
            arguments: ["config", "run", "--verbose", "--config", swiftgen.configPath],
            environment: swiftgen.environment,
            outputFilesDirectory: swiftgen.outputFilesPath
        )
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
