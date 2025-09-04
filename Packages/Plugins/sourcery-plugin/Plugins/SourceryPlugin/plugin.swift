import Foundation
import PackagePlugin

@main
struct SourceryPlugin: CommandPlugin {

  func performCommand(context: PluginContext, arguments: [String]) async throws {
    print("Package directory is \(context.package.directory)")
    let targets: [Target] = context.package.targets
      .compactMap { $0 as? SourceModuleTarget }
      .map {
        Target(
          name: $0.name,
          basePath: $0.directory
        )
      }
    try Command.run(targets: targets, workDirectory: context.pluginWorkDirectory)
  }
}

#if canImport(XcodeProjectPlugin)
  import XcodeProjectPlugin

  extension SourceryPlugin: XcodeCommandPlugin {

    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
      print("Launching SourceryPlugin on \(context.xcodeProject.directory)")
      let targets: [Target] = context.xcodeProject.targets
        .filter({ arguments.contains($0.displayName) })
        .map {
          Target(
            name: $0.displayName,
            basePath: context.xcodeProject.directory.appending(subpath: $0.displayName)
          )
        }
      try Command.run(targets: targets, workDirectory: context.pluginWorkDirectory)
    }
  }
#endif

struct Target {
  let name: String
  let basePath: Path
}

enum Command {
  static func run(targets: [Target], workDirectory: Path) throws {
    for target in targets {
      guard let yamlPath = self.yamlPath(at: target.basePath) else {
        Diagnostics.remark("Sourcery configuration was not found for \(target.name). Skipping.")
        continue
      }

      try runTool(
        at: try sourceryPath(),
        arguments: [
          "--config",
          yamlPath.string,
          "--cacheBasePath",
          workDirectory.string,
          "--verbose",
        ]
      )
    }
  }

  private static func yamlPath(at base: Path) -> Path? {
    for filename in ["sourcery.yml", ".sourcery.yml"] {
      let yamlPath =
        base
        .appending(filename)
      if FileManager.default.fileExists(atPath: yamlPath.string) {
        return yamlPath
      }
    }
    return nil
  }

  private static func sourceryPath() throws -> Path {
    let availablePaths = [
      "/opt/homebrew/bin/sourcery",
      "/usr/local/bin/sourcery",
    ]
    guard let path = availablePaths.first(where: { FileManager.default.fileExists(atPath: $0) })
    else {
      throw InstallError.missingSourcery
    }
    return Path(path)
  }
}

enum InstallError: Error, CustomDebugStringConvertible {
  case missingSourcery

  var debugDescription: String {
    switch self {
    case .missingSourcery:
      return
        "It looks like Sourcery is not installed on this machine. Please install it using Brew."
    }
  }

}

func runTool(at tool: Path, arguments: [String]) throws {
  let task = Process()
  task.executableURL = URL(fileURLWithPath: tool.string)
  task.arguments = arguments

  print(
    """
    Executing task:
    - \(tool.string)
    - \(arguments)
    """)

  try task.run()
  task.waitUntilExit()

  if task.terminationReason != .exit || task.terminationStatus != 0 {
    let problem = "\(task.terminationReason):\(task.terminationStatus)"
    Diagnostics.error("\(tool) invocation failed: \(problem)")
  }
}
