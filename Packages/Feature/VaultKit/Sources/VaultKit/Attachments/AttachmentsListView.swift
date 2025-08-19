import CoreLocalization
import CorePersonalData
import DocumentServices
import QuickLook
import SwiftTreats
import SwiftUI
import UIDelight

public struct AttachmentsListView: View {
  @StateObject
  var model: AttachmentsListViewModel

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
    .renameAlert(
      isPresented: $model.showRenameDocument,
      filename: $model.newAttachmentName,
      renameFile: { _ in
        Task {
          await self.model.renameAttachment()
        }
      }
    )
    .sheet(isPresented: $model.showQuickLookPreview) {
      if let dataSource = model.previewDataSource {
        QuickLookPreviewView(
          dataSource: dataSource, showQuickLookPreview: $model.showQuickLookPreview)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(Text(CoreL10n.kwAttachementsTitle))
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        AddAttachmentButton(model: model.addAttachmentButtonViewModel)
      }
    }
    .confirmationDialog(
      CoreL10n.kwDeleteConfirm,
      isPresented: $model.showDeleteConfirmation,
      titleVisibility: .visible,
      presenting: model.selectedAttachment
    ) { item in
      Button(
        role: .destructive,
        action: {
          self.model.delete(item)
        }, label: { Text(CoreL10n.kwYes) })
      Button(CoreL10n.kwNo, role: .cancel) {
        model.selectedAttachment = nil
      }
    }.alert(item: $model.error) { error in
      Alert(title: Text(CoreL10n.kwErrorTitle), message: Text(error))
    }
    .documentPicker(export: $model.exportURLMac, completion: {})
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
    model.showDeleteDialog(item)
  }
}

extension View {
  func renameAlert(
    isPresented: Binding<Bool>,
    filename: Binding<String>,
    renameFile: @escaping (String) -> Void
  ) -> some View {
    self.alert(
      CoreL10n.kwDeviceRename,
      isPresented: isPresented,
      actions: {
        TextField(CoreL10n.kwDefaultFilename + ".jpeg", text: filename)
        Button(
          CoreL10n.kwSave,
          action: {
            renameFile(filename.wrappedValue)
          })
        Button(CoreL10n.cancel, role: .cancel, action: {})
      }
    )
  }
}

struct AttachmentsListView_Previews: PreviewProvider {
  static var previews: some View {
    AttachmentsListView(model: .mock)
  }
}

class PreviewDataSource: QLPreviewControllerDataSource, Identifiable {
  let url: URL

  init(url: URL) {
    self.url = url
  }

  func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
  func previewController(_ controller: QLPreviewController, previewItemAt index: Int)
    -> QLPreviewItem
  {
    return url as QLPreviewItem
  }
}
