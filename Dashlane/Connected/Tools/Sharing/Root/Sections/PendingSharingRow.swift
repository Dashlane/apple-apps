import SwiftUI
import UIComponents
import UIDelight
import DesignSystem

enum PendingSharingRowAction {
    case accept
    case refuse
}

struct PendingSharingRow<Content: View>: View {
    typealias Action = PendingSharingRowAction

    @State
    var inProgress: Bool = false

    @State
    var showError: Bool = false

    let action: (Action) async throws -> Void

    @ViewBuilder
    var label: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                label
                Spacer()
                if inProgress {
                    ProgressView()
                }
            }
            HStack {
                Spacer()
                declineButton
                    .disabled(inProgress)

                acceptButton
                    .disabled(inProgress)
            }.controlSize(.mini)
        }
        .padding(.vertical, 8)
        .alert(L10n.Localizable.kwSharingCenterUnknownErrorAlertTitle, isPresented: $showError) {

        }
        .animation(.easeInOut, value: inProgress)
        .buttonStyle(.plain)
    }

        var declineButton: some View {
        RoundedButton(L10n.Localizable.kwDenySharingRequest) {
            perform(.refuse)
        }
        .style(mood: .neutral, intensity: .supershy)
    }

        var acceptButton: some View {
        RoundedButton(L10n.Localizable.kwAcceptSharing) {
            perform(.accept)
        }
        .style(mood: .brand, intensity: .catchy)
    }

    func perform(_ action: Action) {
        Task {
            showError = false
            inProgress = true
            do {
                try await self.action(action)
                inProgress = false
            } catch {
                inProgress = false
                showError = true
            }
        }
    }

}

struct PendingSharingRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                PendingSharingRow { _ in
                   try await Task.sleep(nanoseconds: 2_000_000_000)
                } label: {
                    Text("Pending Item")
                }

                PendingSharingRow { _ in
                    throw URLError(.unknown)
                } label: {
                    Text("Failing Item")
                }
            }
        }.listStyle(.insetGrouped)

    }
}
