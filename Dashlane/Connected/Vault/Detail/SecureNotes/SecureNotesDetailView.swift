import CoreFeature
import CoreLocalization
import CorePersonalData
import DesignSystem
import MarkdownUI
import SwiftTreats
import SwiftUI
import UIDelight
import VaultKit

struct SecureNotesDetailView: View {
  @StateObject var model: SecureNotesDetailViewModel

  @State private var showMarkdownLivePreview: Bool = false

  @FocusState var isEditingContent: Bool

  @FeatureState(.secureNoteMarkdownEnabled) private var secureNoteMarkdownEnabled: Bool

  init(model: @escaping @autoclosure () -> SecureNotesDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    DetailContainerView(service: model.service) {
      mainSection
      colorSection
    } sharingSection: {
      sharingSection
    }
  }

  @ViewBuilder
  private var mainSection: some View {
    Section {
      NotesDetailField(
        title: CoreL10n.KWSecureNoteIOS.title,
        text: $model.item.title
      )
      .limitedRights(model: .init(item: model.item, isFrozen: model.isFrozen, hasInfoButton: false))

      if secureNoteMarkdownEnabled && !model.mode.isEditing {
        MarkdownDetailField(model.item.content)
          .actions([.copy(model.copy)], hasAccessory: false)
          .lineLimit(nil)
          .labeled(CoreL10n.KWSecureNoteIOS.content)
          .limitedRights(
            model: .init(item: model.item, isFrozen: model.isFrozen, hasInfoButton: false))
      } else {
        NotesDetailField(
          title: CoreL10n.KWSecureNoteIOS.content,
          text: $model.item.content
        )
        .actions([.copy(model.copy)], hasAccessory: false)
        .limitedRights(
          model: .init(item: model.item, isFrozen: model.isFrozen, hasInfoButton: false))
      }
    }
  }

  private var sharingSection: some View {
    SharingDetailSection(
      model: model.sharingDetailSectionModelFactory.make(item: model.item),
      ctaLabel: L10n.Localizable.kwShareSecurenote,
      canShare: !model.service.isFrozen
    )
  }

  private var colorSection: some View {
    Section {
      PickerDetailField(
        title: CoreL10n.KWSecureNoteIOS.colorTitle,
        selection: $model.item.color,
        elements: SecureNoteColor.allCases,
        content: { color in
          HStack {
            Circle()
              .fill(color.color)
              .frame(width: 12)
            Text(color.localizedName)
          }
        }
      )
    }
  }
}

#Preview("Secure Note - Viewing") {
  SecureNotesDetailView(
    model: MockVaultConnectedContainer().makeSecureNotesDetailViewModel(
      item: PersonalDataMock.SecureNotes.thinkDifferent,
      mode: .viewing
    )
  )
}

#Preview("Secure Note - Updating") {
  SecureNotesDetailView(
    model: MockVaultConnectedContainer().makeSecureNotesDetailViewModel(
      item: PersonalDataMock.SecureNotes.thinkDifferent,
      mode: .updating
    )
  )
}
