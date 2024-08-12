import SwiftUI

struct ItemsList_Previews: PreviewProvider {
  static let sections: [DataSection] = [
    DataSection(
      name: "Credentials",
      items: PersonalDataMock.Credentials.all),
    DataSection(
      name: "Notes",
      items: PersonalDataMock.SecureNotes.all),
    DataSection(
      name: "Addresses",
      items: PersonalDataMock.Addresses.all),
    DataSection(
      name: "Identity",
      items: PersonalDataMock.Identities.all),
    DataSection(
      name: "Phone",
      items: PersonalDataMock.Phones.all),
    DataSection(
      name: "Company",
      items: PersonalDataMock.Companies.all),
    DataSection(
      name: "Website",
      items: PersonalDataMock.PersonalWebsites.all),
    DataSection(
      name: "Driving License",
      items: PersonalDataMock.DrivingLicences.all),
    DataSection(
      name: "Social Security",
      items: PersonalDataMock.SocialSecurityInformations.all),
  ]

  static var previews: some View {
    Group {
      ItemsList(sections: sections, rowProvider: row)

      VStack(spacing: 0) {
        ItemsList(
          sections: [DataSection(name: "Credentials", items: PersonalDataMock.Credentials.all)],
          rowProvider: row
        )

        VStack {
          Text("Your Premium benefits expire in 30 days.")
            .foregroundColor(.ds.text.neutral.catchy)
          Button("Renew Premium") {}
            .foregroundColor(.ds.text.brand.standard)
        }
      }
    }
    .vaultItemsListDelete(.init(delete))
  }

  static func delete(_ item: VaultItem) {}
  static func select(_ item: VaultItem) {}

  static func row(for rowInput: ItemRowViewConfiguration) -> VaultItemRow {
    VaultItemRow.mock(item: rowInput.vaultItem)
  }
}
