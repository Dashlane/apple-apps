import Foundation

struct SpecifyIcon: Decodable {
    let name: String
    var image: Data?

    var nameComponents: [String] {
        name.components(separatedBy: "/")
            .map { $0.dropFirst().lowercased().replacingOccurrences(of: " ", with: "") }
    }

    private let fetchImageTask: Task<Data, Error>?

    private enum CodingKeys: String, CodingKey {
        case name
        case value
    }

    private enum ValueCodingKeys: String, CodingKey {
        case url
    }

        init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let valueContainer = try container.nestedContainer(
            keyedBy: ValueCodingKeys.self,
            forKey: .value
        )
        name = try container.decode(String.self, forKey: .name)
        let fileURL = try valueContainer.decode(URL.self, forKey: .url)
        fetchImageTask = Task {
            let (data, _) = try await URLSession.shared.data(from: fileURL)
            return data
        }
    }

    private init(name: String, image: Data) {
        self.name = name
        self.image = image
        self.fetchImageTask = nil
    }

        func withImage() async throws -> SpecifyIcon {
        guard let fetchImageTask else { return self }
        return try await .init(name: name, image: fetchImageTask.value)
    }
}
