import CoreFeature
import CoreLocalization
import DashTypes
import DesignSystem
import SwiftUI
import UIComponents
import VaultKit

struct SecureNotesDetailFields: View {
  @StateObject var model: SecureNotesDetailFieldsModel

  @Binding
  var showLivePreview: Bool

  var isEditingContent: FocusState<Bool>.Binding

  @FeatureState(.disableSecureNotes)
  private var secureNotesDisabled: Bool

  @FeatureState(.secureNoteMarkdownEnabled)
  private var secureNoteMarkdownEnabled: Bool

  init(
    model: @escaping @autoclosure () -> SecureNotesDetailFieldsModel,
    isEditingContent: FocusState<Bool>.Binding,
    showLivePreview: Binding<Bool>
  ) {
    self._model = .init(wrappedValue: model())
    self.isEditingContent = isEditingContent
    self._showLivePreview = showLivePreview
  }

  var body: some View {
    VStack(spacing: 0) {
      if model.mode.isEditing || !model.item.title.isEmpty {
        MultilineTitleDetailField(
          text: $model.item.title, placeholder: L10n.Localizable.kwSecureNoteTitle
        )
        .padding(.horizontal, 5)
        .frame(minHeight: 50)
        .focused(isEditingContent)
        .limitedRights(hasInfoButton: false, item: model.item)

        Divider()
          .overlay(Color.ds.border.neutral.quiet.idle)
      }

      if secureNoteMarkdownEnabled {
        SecureNotesTextView(
          text: $model.item.content,
          placeholder: CoreLocalization.L10n.Core.KWSecureNoteIOS.emptyContent,
          isEditable: model.mode.isEditing,
          isSelectable: !secureNotesDisabled,
          showLivePreview: $showLivePreview
        )
        .accessibilityLabel(L10n.Localizable.secureNoteDetails)
        .limitedRights(hasInfoButton: false, item: model.item)
      } else {
        MultilineDetailTextView(
          text: $model.item.content,
          placeholder: CoreLocalization.L10n.Core.KWSecureNoteIOS.emptyContent,
          isEditable: model.mode.isEditing,
          isSelectable: !secureNotesDisabled
        )
        .accessibilityLabel(L10n.Localizable.secureNoteDetails)
        .limitedRights(hasInfoButton: false, item: model.item)
      }
    }
  }
}
