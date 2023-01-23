import SwiftUI
import UIDelight
import DocumentServices
import SwiftTreats
import CorePersonalData

struct AttachmentsListView: View {
    @StateObject
    var model: AttachmentsListViewModel

    @State
    private var itemToDelete: Attachment?

    @State
    private var showDeleteConfirmation: Bool = false

    var body: some View {
        List {
            ForEach(model.attachments, id: \.id) { attachment in
                AttachmentRowView(model: model.rowViewModel(attachment))
            }
            .onDelete(perform: deleteRow)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text(L10n.Localizable.kwAttachementsTitle))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                AddAttachmentButton(model: model.addAttachmentButtonViewModel)
            }
        }
        .confirmationDialog(L10n.Localizable.kwDeleteConfirm,
                            isPresented: $showDeleteConfirmation,
                            titleVisibility: .visible,
                            presenting: itemToDelete) { item in
            Button(role: .destructive, action: {
                self.model.delete(item)
            }, label: {Text(L10n.Localizable.kwYes) })
            Button(L10n.Localizable.kwNo, role: .cancel) {
                self.itemToDelete = nil
            }
        }
        .navigationViewStyle(.stack)
        .onAppear(perform: model.logView)
    }

        private func deleteRow(at indexSet: IndexSet) {
        let items = indexSet.map {
            model.attachments[$0]
        }
        guard let item = items.first else {
            return
        }
        delete(item)
    }

    private func delete(_ item: Attachment) {
        itemToDelete = item
        showDeleteConfirmation = true
    }
}

struct AttachmentsListView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentsListView(model: .mock)
    }
}

extension Attachment: Identifiable {}
