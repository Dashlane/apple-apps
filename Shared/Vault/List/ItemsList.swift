import SwiftUI
import DashlaneAppKit
import VaultKit
import CoreSharing

struct ItemRowViewConfiguration {
    let vaultItem: VaultItem
    let isSuggestedItem: Bool
}

struct ItemsList<RowView: View>: View {

    @Environment(\.vaultItemsListHeaderView)
    var headerView

    @Environment(\.vaultItemsListFloatingHeaderView)
    var floatingHeaderView

    @Environment(\.vaultItemsListDelete)
    var delete

    @Environment(\.vaultItemsListDeleteBehaviour)
    var deleteBehaviour
    
    let sections: [DataSection]
    let rowProvider: (ItemRowViewConfiguration) -> RowView

    @State
    var deleteRequest: DeleteVaultItemRequest = .init()

    @State
    var itemToDelete: VaultItem?

    @State
    private var floatingHeaderViewHeight: CGFloat = 0

    private var sectionIndexesPadding: CGFloat {
        sections.count > 1 ? 10 : 0
    }
    
    init(sections: [DataSection], rowProvider: @escaping (ItemRowViewConfiguration) -> RowView) {
        self.sections = sections
        self.rowProvider = rowProvider
    }
    
    var body: some View {
        list
            .deleteItemAlert(request: $deleteRequest, deleteAction: deleteItem)
            .eraseToAnyView()
    }

        @ViewBuilder
    var list: some View {
        List {
            Section {
                headerView
                .accessibilitySortPriority(.header)

                                VaultForEach(
                    sections: sections,
                    delete: delete != nil ? { deleteRow(at: $0, section: $1) } : nil,
                    header: { section in
                        if section.isSuggestedItems {
                            sectionHeader(for: section)
                        } else {
                            sectionHeader(for: section)
                                .id(section.listIndex)
                        }
                    }, row: { section, item in
                        row(for: item, isSuggestedItem: section.isSuggestedItems)
                    }
                ).accessibilitySortPriority(.list)
            }
            .disableHeaderCapitalization()
        }
        .listStyle(.plain)
        .padding(.top, floatingHeaderViewHeight)
        .overlay(alignment: .top) {
            topOverlay
                .accessibilitySortPriority(.header)
        }
    }

        private var topOverlay: some View {
        floatingHeaderView?
            .background(heightGetterView)
    }

    private var heightGetterView: some View {
        Rectangle()
            .foregroundColor(.clear)
            .onSizeChange { size in
                floatingHeaderViewHeight = size.height
            }
    }

        @ViewBuilder
    private func sectionHeader(for section: DataSection) -> some View {
        if !section.name.isEmpty {
            Text(section.name)
                .font(.headline)
                .padding(.leading, 16)
                .foregroundColor(.ds.text.neutral.quiet)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.ds.background.default)
        }
    }

    private func row(for item: VaultItem, isSuggestedItem: Bool) -> some View {
        self.rowProvider(.init(vaultItem: item, isSuggestedItem: isSuggestedItem))
            .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 10))
            .listRowBackground(Color.ds.background.default)
            .padding(.trailing, sectionIndexesPadding)
    }
    
        private func deleteRow(at indexSet: IndexSet, section: DataSection) {
        let items = indexSet.map {
            section.items[$0]
        }
        guard let item = items.first else {
            return
        }
        Task {
           try await delete(item)
        }
    }

    private func delete(_ item: VaultItem) async throws {
        itemToDelete = item
        deleteRequest.itemDeleteBehavior = try await deleteBehaviour(item)
        deleteRequest.isPresented = true
    }

    private func deleteItem() {
        guard let item = itemToDelete else {
            return
        }
        self.delete?(item)
        itemToDelete = nil
    }

    private func itemDeleteBehavior() async throws -> ItemDeleteBehaviour {
        guard let item = itemToDelete else {
            return .normal
        }
        return try await deleteBehaviour(item)
    }
}

struct ItemsList_Previews: PreviewProvider {
    #if EXTENSION || AUTHENTICATOR
        static let sections: [DataSection] = [DataSection(name: "Credentials",
                                                      items: PersonalDataMock.Credentials.all)]
    #else
    static let sections: [DataSection] = [DataSection(name: "Credentials",
                                                      items: PersonalDataMock.Credentials.all),
                                          DataSection(name: "Notes",
                                                      items: PersonalDataMock.SecureNotes.all),
                                          DataSection(name: "Addresses",
                                                      items: PersonalDataMock.Addresses.all),
                                          DataSection(name: "Identity",
                                                      items: PersonalDataMock.Identities.all),
                                          DataSection(name: "Phone",
                                                      items: PersonalDataMock.Phones.all),
                                          DataSection(name: "Company",
                                                      items: PersonalDataMock.Companies.all),
                                          DataSection(name: "Website",
                                                      items: PersonalDataMock.PersonalWebsites.all),
                                          DataSection(name: "Driving License",
                                                      items: PersonalDataMock.DrivingLicences.all),
                                          DataSection(name: "Social Security",
                                                      items: PersonalDataMock.SocialSecurityInformations.all)]
    #endif

    static var previews: some View {
        Group {
            ItemsList(sections: sections, rowProvider: row)

            ItemsList(
                sections: [DataSection(name: "Credentials", items: PersonalDataMock.Credentials.all)],
                rowProvider: row
            )
            .vaultItemsListFloatingHeader(
                VStack {
                    Text("Your Premium benefits expire in 30 days.")
                        .foregroundColor(.ds.text.neutral.catchy)
                    Button("Renew Premium") { }
                        .foregroundColor(.ds.text.brand.standard)
                }
            )
        }
        .vaultItemsListDelete(.init(delete))
    }

    static func delete(_ item: VaultItem) { }
    static func select(_ item: VaultItem) { }

    #if EXTENSION || AUTHENTICATOR
    static func row(for rowInput: ItemRowViewConfiguration) -> some View {
        return CredentialRowView(model: CredentialRowView_Previews.mockModel) {}
    }
    #else
    static func row(for rowInput: ItemRowViewConfiguration) -> VaultItemRow {
        VaultItemRow(model: .mock(item: rowInput.vaultItem))
    }
    #endif
}
