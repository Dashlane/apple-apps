import CoreLocalization
import CorePersonalData
import DesignSystem
import DesignSystemExtra
import DocumentServices
import SwiftUI
import UIDelight

struct AttachmentsSection: View {
  @StateObject
  var model: AttachmentsSectionViewModel

  @State
  private var showAttachmentsList: Bool = false

  var body: some View {
    Section(CoreL10n.documentsStorageSectionTitle) {
      if !model.itemCollections.isEmpty {
        CoreL10n.collectionLimitation(for: model.item).map {
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
          NativeNavigationPushRow(title: attachmentsButtonTitle) {
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
      ? CoreL10n.existingSecureFilesAttachedCta : CoreL10n.noSecureFilesAttachedCta
  }

  private var attachmentsButtonTitle: String {
    let attachmentsCount: Int = model.item.attachments?.count ?? 0
    return if attachmentsCount == 1 {
      CoreL10n.oneSecureFileAttachedCta
    } else {
      CoreL10n.numberedSecureFilesAttachedCta(attachmentsCount)
    }
  }

  private var sharedItemText: String? {
    CoreL10n.sharingLimitation(for: model.item)
  }
}

extension CoreL10n {
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
