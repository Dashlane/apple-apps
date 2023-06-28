import CoreLocalization
import CorePremium
import DesignSystem
import SwiftUI

struct SpaceSelectorSection: View {

    @Environment(\.spaceSelectorSectionFeedback)
    private var feedbackMessage

    private let selectedUserSpace: UserSpace
    private let isUserSpaceForced: Bool

    @Binding
    private var showSpaceSelector: Bool

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
            Button(action: showSpaceSelectorListView) {
                HStack {
                    UserSpaceIcon(space: selectedUserSpace, size: .normal)
                        .equatable()

                    Text(selectedUserSpace.teamName)
                        .foregroundColor(isUserSpaceForced ? .ds.text.neutral.quiet : .ds.text.neutral.catchy)
                }
            }
            .buttonStyle(DetailRowButtonStyle())
            .disabled(isUserSpaceForced)
        }
    }

    private var sectionHeader: some View {
        HStack {
            Text(L10n.Core.KWAuthentifiantIOS.spaceId.uppercased())
                .font(.footnote)
                .foregroundColor(.ds.text.neutral.quiet)

            if isUserSpaceForced {
                Image.ds.lock.filled
                    .resizable()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.ds.text.neutral.standard)
            }
        }
    }

    @ViewBuilder
    private var sectionFooter: some View {
        if isUserSpaceForced, let feedbackMessage {
            Text(feedbackMessage)
                .font(.footnote)
                .foregroundColor(.ds.text.neutral.quiet)
        }
    }

    private func showSpaceSelectorListView() {
       #if canImport(UIKit)
                UIApplication.shared.endEditing()
        #endif
        showSpaceSelector = true
    }
}

struct SpaceSelectorSection_Previews: PreviewProvider {

    static var previews: some View {
        SpaceSelectorSection(
            selectedUserSpace: .business(.init(space: .mock, anonymousTeamId: "1234")),
            isUserSpaceForced: false,
            showSpaceSelector: .constant(false)
        )
        SpaceSelectorSection(
            selectedUserSpace: .business(.init(space: .mock, anonymousTeamId: "1234")),
            isUserSpaceForced: true,
            showSpaceSelector: .constant(false)
        )
    }
}
