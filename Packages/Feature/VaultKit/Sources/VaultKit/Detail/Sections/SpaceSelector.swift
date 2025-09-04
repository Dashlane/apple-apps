import CoreLocalization
import CorePremium
import DesignSystem
import SwiftUI

struct SpaceSelectorRow: View {
  @Binding private var showSpaceSelector: Bool

  private let selectedUserSpace: UserSpace
  private let isUserSpaceForced: Bool

  init(
    selectedUserSpace: UserSpace,
    isUserSpaceForced: Bool,
    showSpaceSelector: Binding<Bool>
  ) {
    self.selectedUserSpace = selectedUserSpace
    self.isUserSpaceForced = isUserSpaceForced
    self._showSpaceSelector = showSpaceSelector
  }

  var body: some View {
    Button(action: showSpaceSelectorListView) {
      HStack {
        UserSpaceIcon(space: selectedUserSpace, size: .normal)
          .equatable()

        Text(selectedUserSpace.teamName)
          .foregroundStyle(
            isUserSpaceForced ? Color.ds.text.neutral.quiet : Color.ds.text.neutral.catchy)
      }
    }
    .buttonStyle(DetailRowButtonStyle())
    .disabled(isUserSpaceForced)
  }

  private func showSpaceSelectorListView() {
    UIApplication.shared.endEditing()
    showSpaceSelector = true
  }
}

struct SpaceSelectorSection: View {
  @Environment(\.spaceSelectorSectionFeedback) private var feedbackMessage

  @Binding private var showSpaceSelector: Bool

  private let selectedUserSpace: UserSpace
  private let isUserSpaceForced: Bool

  init(
    selectedUserSpace: UserSpace,
    isUserSpaceForced: Bool,
    showSpaceSelector: Binding<Bool>
  ) {
    self.selectedUserSpace = selectedUserSpace
    self.isUserSpaceForced = isUserSpaceForced
    self._showSpaceSelector = showSpaceSelector
  }

  public var body: some View {
    Section(header: sectionHeader, footer: sectionFooter) {
      SpaceSelectorRow(
        selectedUserSpace: selectedUserSpace,
        isUserSpaceForced: isUserSpaceForced,
        showSpaceSelector: $showSpaceSelector
      )
    }
  }

  private var sectionHeader: some View {
    HStack {
      Text(CoreL10n.KWAuthentifiantIOS.spaceId.uppercased())
        .font(.footnote)
        .foregroundStyle(Color.ds.text.neutral.quiet)

      if isUserSpaceForced {
        Image.ds.lock.filled
          .resizable()
          .frame(width: 10, height: 10)
          .foregroundStyle(Color.ds.text.neutral.standard)
      }
    }
  }

  @ViewBuilder
  private var sectionFooter: some View {
    if isUserSpaceForced, let feedbackMessage {
      Text(feedbackMessage)
        .font(.footnote)
        .foregroundStyle(Color.ds.text.neutral.quiet)
    }
  }
}

struct SpaceSelectorSection_Previews: PreviewProvider {

  static var previews: some View {
    SpaceSelectorSection(
      selectedUserSpace: .team(.mock()),
      isUserSpaceForced: false,
      showSpaceSelector: .constant(false)
    )
    SpaceSelectorSection(
      selectedUserSpace: .team(.mock()),
      isUserSpaceForced: true,
      showSpaceSelector: .constant(false)
    )
  }
}
