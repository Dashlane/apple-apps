#if os(iOS)
import CoreFeature
import CoreLocalization
import CoreMedia
import DesignSystem
import DocumentServices
import SwiftTreats
import SwiftUI
import UIDelight
import UIComponents

struct AttachmentRowView: View {
    @StateObject
    var model: AttachmentRowViewModel

    @State
    private var showQuickLookPreview: Bool = false

    @State
    private var exportURLMac: URL?

    @State
    private var showRenameDocument: Bool = false

    @State
    private var showDeleteConfirmation: Bool = false

    @FeatureState(.documentStorageAllItems)
    var isRenamingDocumentsEnabled: Bool

    var body: some View {
        HStack {
            attachmentIconView
                .frame(width: 20)
            titleview
            Spacer()
            actions
        }
    }

    @ViewBuilder
    var attachmentIconView: some View {
        switch model.state {
        case .downloaded:
            Image(asset: Asset.attachmentClipDownloaded)
        default:
            Image(asset: Asset.attachmentClip)
        }
    }

    var titleview: some View {
        VStack(alignment: .leading) {
            Text(model.attachment.filename)
                .foregroundColor(.ds.text.neutral.catchy)
                .font(.callout)
            Group {
                Text(L10n.Core.kwUploaded(model.creationDate))
                Text(model.attachment.localSize.readableFileSizeFormat)
            }
            .foregroundColor(.ds.text.neutral.quiet)
            .font(.footnote)
        }
        .confirmationDialog(
            L10n.Core.kwDeleteConfirm,
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible,
            actions: {
                Button(L10n.Core.kwYes, role: .destructive) { model.delete() }
                Button(L10n.Core.kwNo, role: .cancel) {}
            }
        )
       .alert(item: $model.error) { error in
           Alert(title: Text(L10n.Core.kwErrorTitle), message: Text(error))
       }
    }

    var actions: some View {
        menu
        .padding(.trailing, 10)
        .animation(.default, value: model.state)
        .sheet(isPresented: $showQuickLookPreview) {
            model.previewDataSource.map {
                QuickLookPreviewView(dataSource: $0, showQuickLookPreview: $showQuickLookPreview)
            }
        }
        .documentPicker(export: $exportURLMac, completion: { })
        .renameAlert(isPresented: $showRenameDocument,
                     filename: $model.filename,
                     renameFile: {_ in self.model.renameAttachment() })
    }

    var menu: some View {
        Menu {
                        if model.state == .idle {
                Button {
                    Task.detached {
                        let url = try await self.model.download()
                        if Device.isMac {
                            await self.openSavePanel(url)
                        }
                    }
                } label: {
                    Text(L10n.Core.kwDownloadAttachment)
                    Image.ds.download.outlined
                }
            } else if model.state == .downloaded {
                Button {
                    Task.detached {
                        let url = try await self.model.getDownloadedFileURL()
                        await self.presentQuickLookPreview(url: url)
                    }
                } label: {
                    Text(L10n.Core.kwOpen)
                    Image.ds.action.reveal.outlined
                }

            }

                        if isRenamingDocumentsEnabled {
                Button {
                    self.showRenameDocument = true
                } label: {
                    Text(L10n.Core.kwDeviceRename)
                    Image.ds.action.edit.filled
                }
            }

                        Button(role: .destructive) {
                self.showDeleteConfirmation = true
            } label: {
                Text(L10n.Core.kwDelete)
                Image(systemName: "trash")
            }

        } label: {
            switch model.state {
            case let .loading(_, loadingType):
                loadingView(for: loadingType)
            default:
                Image.ds.action.more.outlined
                    .resizable()
                    .frame(width: 20, height: 20)
                    .transition(.opacity)
                    .accessibility(label: Text(L10n.Core.kwActions))
            }
        }
        .disabled(model.state.isLoading)
    }

    @ViewBuilder
    private func loadingView(for loadingType: AttachmentRowViewModel.State.LoadingType) -> some View {
        Image(systemName: loadingType.imageName)
            .resizable()
            .frame(width: 8, height: 10)
            .overlay(loadingCircle)
            .padding(.trailing, 6)
            .transition(.opacity)
    }

    @ViewBuilder
    var loadingCircle: some View {
        if let progress = model.progress {
            CircularProgressBar(progress: progress, color: .ds.text.neutral.catchy)
                .frame(width: 20, height: 20)
        }
    }

    @MainActor
    private func presentQuickLookPreview(url: URL) {
        model.previewDataSource = PreviewDataSource(url: url)
        showQuickLookPreview = true
    }

        @MainActor
    private func openSavePanel(_ url: URL) {
        exportURLMac = url
    }
}

extension View {
    func renameAlert(isPresented: Binding<Bool>,
                     filename: Binding<String>,
                     renameFile: @escaping (String) -> Void) -> some View {
            self.alert(
                L10n.Core.kwDeviceRename,
                isPresented: isPresented,
                actions: {
                    TextField(L10n.Core.kwDefaultFilename + ".jpeg", text: filename)
                    Button(L10n.Core.kwSave, action: { renameFile(filename.wrappedValue) })
                    Button(L10n.Core.cancel, role: .cancel, action: {})
                }
            )
    }
}

struct AttachmentRowView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            List {
                AttachmentRowView(model: .mock)
            }
        }
    }
}

extension Int {
    var readableFileSizeFormat: String {
        let byteFormatter = ByteCountFormatter()
                byteFormatter.countStyle = .memory
        return byteFormatter.string(fromByteCount: Int64(self))
    }
}

private struct AttachmentRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17.0, weight: .medium))
            .padding(.leading, 5)
            .frame(width: 10, alignment: .center)
            .background(Color.clear)
    }
}

private extension AttachmentRowViewModel.State.LoadingType {
    var imageName: String {
        switch self {
        case .download: return "arrow.down"
        case .upload: return "arrow.up"
        }
    }
}
#endif
