import CoreLocalization
import CorePersonalData
import SwiftUI

public struct VaultForEach<Header: View, Row: View>: View {
  private struct Element: Identifiable {
    let item: VaultItem
    let section: DataSection

    var id: String {
      return section.id + String(section.isSuggestedItems) + item.id.rawValue
    }
  }

  public typealias DeleteHandler = (VaultItem) -> Void

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
    ForEach(sections) { section in
      Section(header: header(section)) {
        ForEach(
          section.items.lazy.map {
            Element(item: $0, section: section)
          }
        ) { element in
          self.row(section, element.item)
            .swipeActions(edge: .trailing) {
              if let delete {
                Button {
                  delete(element.item)
                } label: {
                  Label(CoreL10n.kwDelete, systemImage: "trash.fill")
                    .labelStyle(.titleAndIcon)
                }
                .tint(.ds.container.expressive.danger.catchy.idle)
              }
            }
        }
      }
    }
  }
}

#Preview {
  List {
    VaultForEach(
      sections: [
        DataSection(
          name: "Credentials",
          items: [
            Credential(login: "_", title: "Credential 1", password: "12345"),
            Credential(login: "_", title: "Credential 2", password: "123456"),
            Credential(login: "_", title: "Credential 3", password: "123457"),
          ]
        )
      ],
      header: { section in
        Text(section.name)
      },
      row: { _, item in
        Text(item.localizedTitle)
      }
    )
  }
}
