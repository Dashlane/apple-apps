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

        try run(
          tool: configuration.toolPath,
          arguments: ["config", "run", "--verbose", "--config", yamlPath.string],
          environment: configuration.environment)
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
      return
        "It looks like SwiftGen is not installed on this machine. Please install it using Brew."
    }
  }

}

private struct SwiftGenCommandConfiguration {

  let toolPath: Path
  let configPath: Path
  let inputFilesPath: Path
  let outputFilesPath: Path
  let environment: [String: String]

  static var toolPath: String? {
    let availablePaths = [
      "/opt/homebrew/bin/swiftgen",
      "/usr/local/bin/swiftgen",
    ]
    guard let path = availablePaths.first(where: { FileManager.default.fileExists(atPath: $0) })
    else {
      return nil
    }
    return path
  }

  init(context: PluginContext, target: Target) throws {
    guard let path = Self.toolPath else {
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
      "OUTPUT_DIR": outputFilesPath.string,
    ]
  }

  #if canImport(XcodeProjectPlugin)
    init(yaml: Path, context: XcodePluginContext, target: XcodeTarget) throws {
      guard let path = Self.toolPath else {
        throw InstallError.missingSwiftgen
      }

      let targetPath = target.targetPath(base: context.xcodeProject.directory)
      let resourcesFolder = targetPath.appending("Resources")
      let configFile = targetPath.appending("swiftgen.yml")
      self.toolPath = Path(path)
      self.configPath = configFile
      self.inputFilesPath = resourcesFolder
      self.outputFilesPath = targetPath.appending("Generated")
      self.environment = [
        "INPUT_DIR": resourcesFolder.string,
        "OUTPUT_DIR": outputFilesPath.string,
      ]
    }
  #endif
}

extension Command {
  fileprivate static func swiftgenCommand(for swiftgen: SwiftGenCommandConfiguration) -> Command {

    let inputFiles = try! FileManager.default.contentsOfDirectory(
      atPath: swiftgen.inputFilesPath.string
    ).map(Path.init)
    let outputFiles = try! FileManager.default.contentsOfDirectory(
      atPath: swiftgen.outputFilesPath.string
    ).map(Path.init)

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

  print(
    """
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

#if canImport(XcodeProjectPlugin)
  import XcodeProjectPlugin

  extension SwiftGenPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
      print("Launching SwiftgenPlugin on \(context.xcodeProject.directory)")
      for target in context.xcodeProject.targets.filter({ Set(arguments).contains($0.displayName) })
      {
        let yamls = self.yamlPaths(of: target, from: context.xcodeProject.directory)
        guard !yamls.isEmpty else {
          print("Swiftgen configuration was not found for \(target.displayName). Skipping")
          continue
        }
        for yaml in yamls {
          print("Swiftgen configuration found for \(target.displayName)")
          let configuration = try SwiftGenCommandConfiguration(
            yaml: yaml, context: context, target: target)

          try? FileManager.default.createDirectory(
            atPath: configuration.outputFilesPath.string,
            withIntermediateDirectories: true
          )
          try run(
            tool: configuration.toolPath,
            arguments: ["config", "run", "--verbose", "--config", yaml.string],
            environment: configuration.environment)
        }
      }
    }

    func yamlPaths(of target: XcodeTarget, from base: PackagePlugin.Path) -> [Path] {
      guard
        let enumerator = FileManager.default.enumerator(
          at: URL(fileURLWithPath: base.appending(subpath: target.displayName).string),
          includingPropertiesForKeys: [.isRegularFileKey],
          options: [.skipsHiddenFiles, .skipsPackageDescendants])
      else {
        return []
      }

      var configs = [Path]()
      for case let url as URL in enumerator where url.absoluteString.hasSuffix("swiftgen.yml") {
        configs.append(Path(url.path))
      }
      return configs
    }
  }

  extension XcodePluginContext: PluginWorkDirectoryProvider {}

  extension XcodeTarget {
    func targetPath(base: Path) -> Path {
      return base.appending(subpath: displayName)
    }
  }
#endif

extension PluginContext: PluginWorkDirectoryProvider {}

protocol PluginWorkDirectoryProvider {
  var pluginWorkDirectory: PackagePlugin.Path { get }
}
