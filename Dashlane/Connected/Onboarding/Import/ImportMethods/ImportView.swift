import DesignSystem
import Foundation
import SwiftUI

struct ImportView: View {
  let importSource: ImportSource

  @Environment(\.dismiss)
  private var dismiss

  init(importSource: ImportSource) {
    self.importSource = importSource
  }

  var body: some View {
    NavigationStack {
      VStack {
        header

        List {
          ImportSection(header: Text(L10n.Localizable.importSourceAnotherManager)) {
            importRow(for: .otherPasswordManagers)
          }

          ImportSection(header: Text(L10n.Localizable.importSourceOther)) {
            importRow(for: .dashlaneBackup)
            if importSource == .onboardingChecklist {
              importRow(for: .addManually)
            }
          }
        }
        .listStyle(.insetGrouped)
        .environment(\.defaultMinListRowHeight, 16)
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button(L10n.Localizable.importButtonCancel) {
              dismiss()
            }
          }
        }
      }
      .background(Color.ds.background.alternate)
      .navigationDestination(for: ImportMethod.self) { destination in
        destinationView(for: destination)
      }
    }
  }

  private var header: some View {
    VStack(alignment: .leading) {
      DS.ExpressiveIcon(.ds.upload.outlined)
        .style(mood: .brand)
        .controlSize(.extraLarge)
        .padding(.bottom, 24)

      Text(L10n.Localizable.importSourceDataTitle)
        .textStyle(.title.section.large)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .multilineTextAlignment(.leading)
    }
    .padding(.top, 16)
    .padding(.leading, -16)
  }

  @ViewBuilder
  private func importRow(for method: ImportMethod) -> some View {
    ImportMethodRowView(method: method) { icon in
      switch method {
      case .otherPasswordManagers:
        Thumbnail.VaultItem.login
      case .dashlaneBackup:
        Thumbnail.login(icon)
      case .addManually:
        if let icon = icon {
          Thumbnail.icon(icon)
        }
      }
    }
  }

  @ViewBuilder
  private func destinationView(for destination: ImportMethod) -> some View {
    switch destination {
    case .otherPasswordManagers:
      EmptyView()
    case .dashlaneBackup:
      EmptyView()
    case .addManually:
      EmptyView()
    }
  }
}

struct ImportSection<Content: View>: View {
  let header: Text
  let content: Content

  init(header: Text, @ViewBuilder content: () -> Content) {
    self.header = header
    self.content = content()
  }

  var body: some View {
    Section(header: header) {
      spacer
      content
      spacer
    }
  }

  private var spacer: some View {
    Color.clear
      .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
      .frame(height: 16)
  }
}

enum ImportSource {
  case onboardingChecklist
  case vaultList
}

enum ImportMethod: Hashable {
  case otherPasswordManagers
  case dashlaneBackup
  case addManually
}

extension ImportMethod {
  fileprivate var icon: Image? {
    switch self {
    case .otherPasswordManagers:
      return nil
    case .dashlaneBackup:
      return Image(.primaryAppIcon)
    case .addManually:
      return Image.ds.action.add.outlined
    }
  }

  fileprivate var title: String {
    switch self {
    case .otherPasswordManagers:
      return L10n.Localizable.importSourceOtherManagersTitle
    case .dashlaneBackup:
      return L10n.Localizable.importSourceDashlaneBackupTitle
    case .addManually:
      return L10n.Localizable.importSourceManuallyTitle
    }
  }

  fileprivate var subtitle: String? {
    switch self {
    case .otherPasswordManagers:
      return L10n.Localizable.importSourceOtherManagersSubtitle
    case .dashlaneBackup:
      return L10n.Localizable.importSourceDashlaneBackupSubtitle
    case .addManually:
      return nil
    }
  }
}

struct ImportMethodRowView<Icon: View>: View {
  let method: ImportMethod
  let icon: Icon

  init(method: ImportMethod, @ViewBuilder icon: (Image?) -> Icon) {
    self.method = method
    self.icon = icon(method.icon)
  }

  var body: some View {
    NavigationLink(value: method) {
      HStack(spacing: 12) {
        icon
          .foregroundStyle(Color.ds.container.decorative.grey)

        VStack(alignment: .leading) {
          Text(method.title)
            .textStyle(.body.standard.regular)
            .foregroundStyle(Color.ds.text.neutral.catchy)

          if let subtitle = method.subtitle {
            Text(subtitle)
              .textStyle(.body.reduced.regular)
              .foregroundStyle(Color.ds.text.neutral.quiet)
          }
        }
      }
    }
    .listRowSeparator(.hidden)
    .foregroundStyle(Color.accent, Color.accent)
  }
}

#Preview {
  ImportView(importSource: .onboardingChecklist)
}

#Preview {
  ImportView(importSource: .vaultList)
}
