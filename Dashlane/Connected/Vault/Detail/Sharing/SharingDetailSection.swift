import CoreFeature
import CoreLocalization
import SwiftUI
import UIComponents
import VaultKit

@MainActor
struct SharingDetailSection: View {
  let model: SharingDetailSectionModel
  let ctaLabel: String

  @Environment(\.detailMode)
  var detailMode

  @Environment(\.navigator)
  var navigator

  var body: some View {
    if !detailMode.isAdding {
      if model.item.hasAttachments {
        Section(CoreLocalization.L10n.Core.KWVaultItem.Sharing.Section.title) {
          CoreLocalization.L10n.Core.attachmentsLimitation(for: model.item).map {
            Text($0)
              .textStyle(.body.reduced.regular)
              .foregroundStyle(Color.ds.text.neutral.quiet)
              .padding(.vertical, 2)
          }
        }
      } else {
        activeSharingSection

        if !detailMode.isEditing && !model.item.hasAttachments && model.item.metadata.isShareable {
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
      Section(CoreLocalization.L10n.Core.KWVaultItem.Sharing.Section.title) {
        SharingMembersDetailLink(model: model.makeSharingMembersDetailLinkModel())

        if case .limited = model.item.metadata.sharingPermission {
          Text(CoreLocalization.L10n.Core.KWVaultItem.Sharing.LimitedRights.message)
            .textStyle(.body.reduced.regular)
            .foregroundStyle(Color.ds.text.neutral.quiet)
        }
      }
    }
  }
}

extension CoreLocalization.L10n.Core {
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
