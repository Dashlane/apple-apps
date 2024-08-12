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
        title: CoreLocalization.L10n.Core.KWSecureNoteIOS.title,
        text: $model.item.title
      )
      .limitedRights(hasInfoButton: false, item: model.item)

      if secureNoteMarkdownEnabled && !model.mode.isEditing {
        MarkdownDetailField(model.item.content)
          .actions([.copy(model.copy)], hasAccessory: false)
          .lineLimit(nil)
          .labeled(CoreLocalization.L10n.Core.KWSecureNoteIOS.content)
          .limitedRights(hasInfoButton: false, item: model.item)
      } else {
        NotesDetailField(
          title: CoreLocalization.L10n.Core.KWSecureNoteIOS.content,
          text: $model.item.content
        )
        .actions([.copy(model.copy)], hasAccessory: false)
        .limitedRights(hasInfoButton: false, item: model.item)
      }
    }
  }

  private var sharingSection: some View {
    SharingDetailSection(
      model: model.sharingDetailSectionModelFactory.make(item: model.item),
      ctaLabel: L10n.Localizable.kwShareSecurenote
    )
  }

  private var colorSection: some View {
    Section {
      PickerDetailField(
        title: CoreLocalization.L10n.Core.KWSecureNoteIOS.colorTitle,
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

#Preview {
  MultiContextPreview {
    SecureNotesDetailView(
      model: MockVaultConnectedContainer().makeSecureNotesDetailViewModel(
        item: PersonalDataMock.SecureNotes.thinkDifferent, mode: .viewing))
    SecureNotesDetailView(
      model: MockVaultConnectedContainer().makeSecureNotesDetailViewModel(
        item: PersonalDataMock.SecureNotes.thinkDifferent, mode: .updating))
  }
}
