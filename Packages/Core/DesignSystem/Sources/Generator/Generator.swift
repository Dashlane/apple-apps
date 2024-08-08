import ArgumentParser
import Foundation

@main
struct Generator: AsyncParsableCommand {
  @Argument(help: "Path to the Design System package")
  var path: String

  @Argument(help: "API token for Specify (stored in Vault)")
  var apiToken: String

  func run() async throws {
    let destination = URL(fileURLWithPath: path)
    do {
      try await ColorGenerator(destination: destination, apiToken: apiToken).generate()
      try await IconGenerator(destination: destination, apiToken: apiToken).generate()
      try await TypographyGenerator(destination: destination, apiToken: apiToken).generate()
    } catch {
      Generator.exit(withError: error)
    }
  }
}
