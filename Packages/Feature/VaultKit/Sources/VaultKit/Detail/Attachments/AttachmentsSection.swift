import CoreLocalization
import DesignSystem
import DocumentServices
import SwiftUI
import UIComponents
import UIDelight

struct AttachmentsSection: View {
  @StateObject
  var model: AttachmentsSectionViewModel

  @State
  private var showAttachmentsList: Bool = false

  var body: some View {
    Section(L10n.Core.documentsStorageSectionTitle) {
      if !model.itemCollections.isEmpty {
        CoreLocalization.L10n.Core.collectionLimitation(for: model.item).map {
          Text($0)
            .textStyle(.body.reduced.regular)
            .foregroundStyle(Color.ds.text.neutral.quiet)
            .padding(.vertical, 2)
        }
      } else if model.item.isShared {
        sharedItemText.map {
          Text($0)
            .textStyle(.body.reduced.regular)
            .foregroundStyle(Color.ds.text.neutral.quiet)
            .padding(.vertical, 2)
        }
      } else {
        if model.item.hasAttachments {
          LinkDetailField(title: attachmentsButtonTitle) {
            showAttachmentsList = true
          }
          .navigation(isActive: $showAttachmentsList) {
            model.makeAttachmentsListViewModel().map {
              AttachmentsListView(model: $0)
            }
          }
        }
        AddAttachmentButton(model: model.addAttachmentButtonViewModel) {
          HStack {
            Text(addAttachmentButtonTitle)
              .frame(maxWidth: .infinity, alignment: .leading)
              .foregroundStyle(
                model.uploadInProgress
                  ? Color.ds.text.oddity.disabled : Color.ds.text.brand.standard
              )

            if let progress = model.progress, model.uploadInProgress {
              CircularProgressBar(
                progress: progress,
                color: .ds.border.brand.standard.idle
              )
              .frame(width: 20, height: 20)
            }
          }
        }
        .disabled(model.uploadInProgress)
        .buttonStyle(DetailRowButtonStyle())
        .accessibilityLabel(addAttachmentButtonTitle)
      }
    }
  }

  private var addAttachmentButtonTitle: String {
    model.item.hasAttachments
      ? L10n.Core.existingSecureFilesAttachedCta : L10n.Core.noSecureFilesAttachedCta
  }

  private var attachmentsButtonTitle: String {
    let attachmentsCount: Int = model.item.attachments?.count ?? 0
    return if attachmentsCount == 1 {
      L10n.Core.oneSecureFileAttachedCta
    } else {
      L10n.Core.numberedSecureFilesAttachedCta(attachmentsCount)
    }
  }

  private var sharedItemText: String? {
    CoreLocalization.L10n.Core.sharingLimitation(for: model.item)
  }
}

extension CoreLocalization.L10n.Core {
  fileprivate static func collectionLimitation(for item: VaultItem) -> String? {
    return switch item.enumerated {
    case .credential:
      Self.KWVaultItem.Attachments.CollectionLimitation.Message.credential
    case .secureNote:
      Self.KWVaultItem.Attachments.CollectionLimitation.Message.secureNote
    default:
      nil
    }
  }

  fileprivate static func sharingLimitation(for item: VaultItem) -> String? {
    return switch item.enumerated {
    case .credential:
      Self.KWVaultItem.Attachments.SharingLimitation.Message.credential
    case .secureNote:
      Self.KWVaultItem.Attachments.SharingLimitation.Message.secureNote
    case .secret:
      Self.KWVaultItem.Attachments.SharingLimitation.Message.secret
    default:
      nil
    }
  }
}
