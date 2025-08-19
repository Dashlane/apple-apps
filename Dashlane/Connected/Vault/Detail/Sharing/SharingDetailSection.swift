import CoreFeature
import CoreLocalization
import CorePersonalData
import SwiftUI
import UIComponents
import VaultKit

@MainActor
struct SharingDetailSection: View {
  let model: SharingDetailSectionModel
  let ctaLabel: String
  let canShare: Bool

  @Environment(\.detailMode)
  var detailMode

  var shouldShowShareButton: Bool {
    !detailMode.isEditing && !model.item.hasAttachments && model.item.metadata.isShareable
      && canShare
  }

  var body: some View {
    if !detailMode.isAdding {
      if model.item.hasAttachments {
        Section(CoreL10n.KWVaultItem.Sharing.Section.title) {
          CoreL10n.attachmentsLimitation(for: model.item).map {
            Text($0)
              .textStyle(.body.reduced.regular)
              .foregroundStyle(Color.ds.text.neutral.quiet)
              .padding(.vertical, 2)
          }
        }
      } else {
        activeSharingSection

        if shouldShowShareButton {
          Section {
            shareButton
          }
        }
      }
    }
  }

  @ViewBuilder
  var shareButton: some View {
    ShareButton(model: model.makeShareButtonViewModel()) {
      Text(ctaLabel)
    }
    .buttonStyle(DetailRowButtonStyle())
  }

  @ViewBuilder
  var activeSharingSection: some View {
    if model.item.isShared {
      Section(CoreL10n.KWVaultItem.Sharing.Section.title) {
        SharingMembersDetailLink(model: model.makeSharingMembersDetailLinkModel())
          .foregroundStyle(Color.ds.text.neutral.catchy)

        if case .limited = model.item.metadata.sharingPermission {
          Text(CoreL10n.KWVaultItem.Sharing.LimitedRights.message)
            .textStyle(.body.reduced.regular)
            .foregroundStyle(Color.ds.text.neutral.quiet)
        }
      }
    }
  }
}

extension CoreL10n {
  fileprivate static func attachmentsLimitation(for item: VaultItem) -> String? {
    return switch item.enumerated {
    case .credential:
      Self.KWVaultItem.Sharing.AttachmentsLimitation.Message.credential
    case .secureNote:
      Self.KWVaultItem.Sharing.AttachmentsLimitation.Message.secureNote
    default:
      nil
    }
  }
}
