import CorePersonalData
import SwiftUI

#if DEBUG
  #Preview {
    let sections = [
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

    Group {
      ItemsList(sections: sections, rowProvider: { VaultItemRow.mock(item: $0.vaultItem) })

      VStack(spacing: 0) {
        ItemsList(
          sections: [DataSection(name: "Credentials", items: PersonalDataMock.Credentials.all)],
          rowProvider: { VaultItemRow.mock(item: $0.vaultItem) }
        )

        VStack {
          Text("Your Premium benefits expire in 30 days.")
            .foregroundStyle(Color.ds.text.neutral.catchy)
          Button("Renew Premium") {}
            .foregroundStyle(Color.ds.text.brand.standard)
        }
      }
    }
    .vaultItemsListDelete(ItemsListDelete { _ in })
  }
#endif
