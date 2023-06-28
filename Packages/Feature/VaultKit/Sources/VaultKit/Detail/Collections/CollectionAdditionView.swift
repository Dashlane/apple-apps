#if os(iOS)
import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIComponents

public struct CollectionAdditionView: View {

    public enum Completion {
        case cancel
        case done(collectionName: String)
    }

                let allCollections: [VaultCollection]

        let collections: [VaultCollection]
    let completion: (Completion) -> Void

    @State
    private var newCollectionName: String = ""

    @FocusState
    private var textFieldFocus

    private var formattedCollectionName: String {
        newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isNameAlreadyExisting: Bool {
        allCollections.contains(where: { $0.name == formattedCollectionName })
    }

    private var canBeCreatedOrAdded: Bool {
        !formattedCollectionName.isEmpty && !isNameAlreadyExisting
    }

    private var filteredCollections: [VaultCollection] {
        collections.filter { $0.name.lowercased().hasPrefix(formattedCollectionName.lowercased()) }
    }

    public init(
        allCollections: [VaultCollection],
        collections: [VaultCollection],
        completion: @escaping (Completion) -> Void
    ) {
        self.allCollections = allCollections.sortedByName()
        self.collections = collections.sortedByName()
        self.completion = completion
    }

    public var body: some View {
        NavigationView {
            List {
                                                Section {
                    TextField(L10n.Core.KWVaultItem.Collections.add, text: $newCollectionName)
                        .submitLabel(.done)
                        .focused($textFieldFocus)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .onSubmit(createOrAdd)

                    if canBeCreatedOrAdded {
                        collectionRow(name: formattedCollectionName)
                    }

                    ForEach(filteredCollections) { collection in
                        collectionRow(collection)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(Color.ds.background.alternate)
            .scrollContentBackground(.hidden)
            .padding(.top, -16) 
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { completion(.cancel) }, title: L10n.Core.cancel)
                }
            }
            .tint(.ds.text.brand.standard)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    self.textFieldFocus = true
                }
            }
        }
    }

    func collectionRow(name: String) -> some View {
        Button(action: { completion(.done(collectionName: name)) }, label: {
            HStack {
                Text(L10n.Core.KWVaultItem.Collections.create)
                    .font(.body)
                    .lineLimit(1)
                    .foregroundColor(.ds.text.brand.standard)

                Tag(name)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        })
        .buttonStyle(.plain)
    }

    func collectionRow(_ collection: VaultCollection) -> some View {
        Button(
            action: { completion(.done(collectionName: collection.name)) },
            label: {
                HStack {
                    Tag(collection.name)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
        )
        .buttonStyle(.plain)
    }

    private func createOrAdd() {
        guard canBeCreatedOrAdded else { return }
        completion(.done(collectionName: formattedCollectionName))
    }
}

struct CollectionAdditionView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionAdditionView(
            allCollections: [PersonalDataMock.Collections.finance],
            collections: [PersonalDataMock.Collections.business]
        ) { _ in }
    }
}
#endif
