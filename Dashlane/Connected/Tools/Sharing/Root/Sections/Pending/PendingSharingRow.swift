import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

enum PendingSharingRowAction {
  case accept
  case refuse
}

struct PendingSharingRow<Content: View>: View {
  typealias Action = PendingSharingRowAction

  @State
  var inProgressAction: Action?

  @State
  var showError: Bool = false

  let action: (Action) async throws -> Void

  @ViewBuilder
  var label: Content

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      label

      HStack {
        let disabled = inProgressAction != nil
        Spacer()
        declineButton
          .disabled(disabled)

        acceptButton
          .disabled(disabled)
      }.controlSize(.mini)
    }
    .padding(.vertical, 8)
    .alert(L10n.Localizable.kwSharingCenterUnknownErrorAlertTitle, isPresented: $showError) {

    }
    .animation(.easeInOut, value: inProgressAction)
    .buttonStyle(.plain)
  }

  var declineButton: some View {
    Button(L10n.Localizable.kwDenySharingRequest) {
      perform(.refuse)
    }
    .buttonStyle(.designSystem(.titleOnly))
    .style(mood: .neutral, intensity: .supershy)
    .buttonDisplayProgressIndicator(inProgressAction == .refuse)
    .disabled(inProgressAction == .accept)
  }

  var acceptButton: some View {
    Button(L10n.Localizable.kwAcceptSharing) {
      perform(.accept)
    }
    .buttonStyle(.designSystem(.titleOnly))
    .style(mood: .brand, intensity: .catchy)
    .buttonDisplayProgressIndicator(inProgressAction == .accept)
  }

  func perform(_ action: Action) {
    Task {
      showError = false
      inProgressAction = action
      defer {
        inProgressAction = nil
      }
      do {
        try await self.action(action)
      } catch {
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
    }.listStyle(.ds.insetGrouped)

  }
}
