import Foundation

struct MaverickResponse: Encodable {
    let id: Int
    let tabId: String
    let message: MaverickResponseMessage

    func communicationBody() -> [String: Any] {
        guard let encoded = try? JSONEncoder().encode(self) else {
            fatalError("Could not encode")
        }

        guard let dictionary = try? JSONSerialization.jsonObject(with: encoded, options: .allowFragments) as? [String: Any] else {
            fatalError("Not a correct JSON?")
        }

        return dictionary
    }
}

