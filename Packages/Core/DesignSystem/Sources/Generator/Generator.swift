import Foundation
import ArgumentParser

@main
struct Generator: AsyncParsableCommand {
    @Argument(help: "Path to the Design System package")
    var path: String
    
    @Argument(help: "API token for Specify (stored in Vault)")
    var apiToken: String

    func run() async throws {
        do {
            try await ColorGenerator(destination: URL(fileURLWithPath: path), apiToken: apiToken).generate()
            try await IconGenerator(destination: URL(fileURLWithPath: path), apiToken: apiToken).generate()
        } catch {
            Generator.exit(withError: error)
        }
    }
}
