import CorePersonalData
import SwiftUI

public struct VaultForEach<Header: View, Row: View>: View {
        private struct Element: Identifiable {
        let item: VaultItem
        let sectionName: String
        let isSuggested: Bool

        var id: String {
            return sectionName + String(isSuggested) + item.id.rawValue
        }
    }

    public typealias DeleteHandler = (IndexSet, DataSection) -> Void

    let sections: [DataSection]
    let delete: DeleteHandler?
    let header: (DataSection) -> Header
    let row: (DataSection, VaultItem) -> Row

    public init(
        sections: [DataSection],
        delete: DeleteHandler? = nil,
        @ViewBuilder header: @escaping (DataSection) -> Header,
        @ViewBuilder row: @escaping (DataSection, VaultItem) -> Row
    ) {
        self.sections = sections
        self.delete = delete
        self.header = header
        self.row = row
    }

    public var body: some View {
        ForEach(sections, id: \.name) { section in
            Section(header: header(section)) {
                ForEach(section.items.lazy.map {
                    Element(item: $0, sectionName: section.name, isSuggested: section.isSuggestedItems)
                }) { element in
                    self.row(section, element.item)
                        .deleteDisabled(delete == nil)
                }
                .onDelete { indexSet in
                    delete?(indexSet, section)
                }
            }
        }
    }
}

struct VaultForEach_Previews: PreviewProvider {

    private static let sections: [DataSection] = [
        .init(
            items: [Credential(), Credential(), Credential(), Credential()]
        )
    ]

    static var previews: some View {
        List {
            VaultForEach(
                sections: sections,
                header: { section in
                    Text(section.name)
                }, row: { _, item in
                    Text(item.localizedTitle)
                }
            )
        }
    }
}
