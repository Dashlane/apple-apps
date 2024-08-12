import CorePersonalData
import SwiftUI

struct IndexedItemsList_Previews: PreviewProvider {

  static var items: [DataSection] {
    PersonalDataMock.Credentials.all.alphabeticallyGrouped()
  }

  static var allCharacters: [DataSection] {
    return "#abcdefghijklmnopqrstuvwxyz".map {
      DataSection(name: String($0), items: [Credential()])
    }
  }

  static func delete(_ item: VaultItem) {

  }

  #if EXTENSION
    static func row(for input: ItemRowViewConfiguration) -> some View {
      return CredentialRowView(model: CredentialRowView_Previews.mockModel) {}
    }
  #else
    static func row(for input: ItemRowViewConfiguration) -> some View {
      VaultItemRow.mock(item: input.vaultItem)
        .padding(.trailing, 10)
    }
  #endif

  static var previews: some View {
    Group {
      ItemsList(sections: items, rowProvider: row)
        .indexed()

      TabView {
        NavigationView {
          ItemsList(sections: items, rowProvider: row)
            .indexed()
            .navigationTitle("All Characters")
            .navigationBarTitleDisplayMode(.inline)
        }
      }
    }
    .vaultItemsListDelete(.init(delete))
  }
}
