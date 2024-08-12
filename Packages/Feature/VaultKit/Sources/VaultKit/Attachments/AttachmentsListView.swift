import CoreLocalization
import CorePersonalData
import DocumentServices
import SwiftTreats
import SwiftUI
import UIDelight

public struct AttachmentsListView: View {
  @StateObject
  var model: AttachmentsListViewModel

  @State
  private var itemToDelete: Attachment?

  @State
  private var showDeleteConfirmation: Bool = false

  public init(model: @autoclosure @escaping () -> AttachmentsListViewModel) {
    self._model = .init(wrappedValue: model())
  }

  public var body: some View {
    List {
      ForEach(model.attachments, id: \.id) { attachment in
        AttachmentRowView(model: model.rowViewModel(attachment))
      }
      .onDelete(perform: deleteRow)
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(Text(L10n.Core.kwAttachementsTitle))
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        AddAttachmentButton(model: model.addAttachmentButtonViewModel)
      }
    }
    .confirmationDialog(
      L10n.Core.kwDeleteConfirm,
      isPresented: $showDeleteConfirmation,
      titleVisibility: .visible,
      presenting: itemToDelete
    ) { item in
      Button(
        role: .destructive,
        action: {
          self.model.delete(item)
        }, label: { Text(L10n.Core.kwYes) })
      Button(L10n.Core.kwNo, role: .cancel) {
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
