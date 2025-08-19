import CoreFeature
import CoreLocalization
import DesignSystem
import SwiftUI
import UIDelight

@ViewInit
struct AttachmentRowView: View {

  @StateObject
  var model: AttachmentRowViewModel

  var body: some View {
    HStack {
      attachmentIconView
        .frame(width: 20)
      titleview
      Spacer()
      actions
    }
    .animation(.default, value: model.state)
  }

  @ViewBuilder
  var attachmentIconView: some View {
    switch model.state {
    case .downloaded:
      Image(.attachmentClipDownloaded)
    default:
      Image(.attachmentClip)
    }
  }

  var titleview: some View {
    VStack(alignment: .leading) {
      Text(model.name)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .font(.callout)
      Group {
        Text(CoreL10n.kwUploaded(model.creationDate))
        Text(model.fileSize)
      }
      .foregroundStyle(Color.ds.text.neutral.quiet)
      .font(.footnote)
    }
  }

  var actions: some View {
    menu
      .padding(.trailing, 10)
  }

  var menu: some View {
    Menu {
      if model.state == .idle {
        Button {
          model.userAction(.download)
        } label: {
          Text(CoreL10n.kwDownloadAttachment)
          Image.ds.download.outlined
        }
      } else if model.state == .downloaded {
        Button {
          model.userAction(.preview)
        } label: {
          Text(CoreL10n.kwOpen)
          Image.ds.action.reveal.outlined
        }
      }

      Button {
        model.userAction(.rename)
      } label: {
        Text(CoreL10n.kwDeviceRename)
        Image.ds.action.edit.filled
      }

      Button(role: .destructive) {
        model.userAction(.delete)
      } label: {
        Text(CoreL10n.kwDelete)
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
          .accessibility(label: Text(CoreL10n.kwActions))
      }
    }
    .disabled(model.state.isLoading)
  }

  @ViewBuilder
  private func loadingView(for loadingType: AttachmentState.LoadingType) -> some View {
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
}

extension AttachmentState.LoadingType {
  fileprivate var imageName: String {
    switch self {
    case .download: return "arrow.down"
    case .upload: return "arrow.up"
    }
  }
}

#if DEBUG
  extension AttachmentRowView {
    @ViewBuilder
    fileprivate static var preview: some View {
      List {
        AttachmentsSection(model: .mock)
      }
    }
  }

  #Preview {
    AttachmentRowView.preview
  }
#endif
