import Foundation

public struct CallingCodesInformationManager {
    public let callingCodes: [CallingCode]

    public init() {
        do {
            let data = try ResourceType.callingCodes.loadResource()
            callingCodes = try JSONDecoder().decode([CallingCode].self, from: data)
        } catch {
            fatalError("Impossible to load Calling Codes: \(error)")
        }
    }
}
