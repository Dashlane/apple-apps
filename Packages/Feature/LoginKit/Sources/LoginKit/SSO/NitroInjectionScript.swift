import Foundation

struct NitroInjectionScript {
    enum ScriptError: Error {
        case invalidScript
    }

    static func script(callbackURL: String) throws -> String {
        let bundle = Bundle.module
        guard let url = bundle.url(forResource: "NitroInjectionScript", withExtension: "js") else {
            throw ScriptError.invalidScript
        }
        let data = try Data(contentsOf: url)

        guard let script = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "CALLBACK_URL", with: callbackURL) else {
            throw ScriptError.invalidScript
        }
        return script
    }
}
