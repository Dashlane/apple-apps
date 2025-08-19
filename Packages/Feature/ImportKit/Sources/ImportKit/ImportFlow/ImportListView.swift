import CoreLocalization
import CorePersonalData
import DesignSystem
import DesignSystemExtra
import SwiftUI
import UserTrackingFoundation
import VaultKit

public struct ImportListView<Model>: View where Model: ObservableObject, Model: OldImportViewModel {

  public enum Action {
    case saved
    case savingError
  }

  @ObservedObject
  var model: Model

  @Environment(\.report)
  var report

  var items: [VaultItem] {
    model.items.compactMap(\.vaultItem)
  }

  let action: @MainActor (Action) -> Void
  @State var showSpaceConfirmationDialog = false

  public var body: some View {
    VStack {
      title
      passwordList
    }
    .confirmationDialog(
      CoreL10n.teamSpacesSharingAcceptPrompt,
      isPresented: $showSpaceConfirmationDialog,
      titleVisibility: .visible,
      actions: spacePickerDialog
    )
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .overlay(importButton, alignment: .bottom)
    .reportPageAppearance(.importCsvPreviewDataUpload)
  }

  @ViewBuilder
  private var title: some View {
    if !items.isEmpty {
      Text(CoreL10n.m2WImportGenericImportScreenPrimaryTitle(model.items.count))
        .frame(maxWidth: 400, alignment: .leading)
        .textStyle(.title.section.large)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .multilineTextAlignment(.leading)
        .padding(.horizontal, 16)
    } else {
      Text(CoreL10n.importLoadingItems)
    }
  }

  @ViewBuilder
  private var passwordList: some View {
    ScrollView {
      ForEach(items, id: \.id.rawValue) { item in
        ImportItemRowView(
          item: .init(vaultItem: item),
          iconViewModel: .init(item: item, domainIconLibrary: model.iconService.domain)
        )
      }
      .padding(.leading, 16)
      .padding(.trailing, 24)

      Spacer()
        .frame(minHeight: 84)
    }
  }

  private var importButton: some View {
    Button(
      action: {
        save()
      },
      label: {
        Text(CoreL10n.m2WImportGenericImportScreenImport)
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: .infinity)
      }
    )
    .buttonStyle(.designSystem(.titleOnly))
    .buttonDisplayProgressIndicator(model.inProgress)
    .disabled(model.inProgress || !model.isAnyItemSelected)
    .padding(.horizontal, 16)
    .padding(.vertical, 26)
    .background {
      importButtonBackground
    }
  }

  @ViewBuilder
  func spacePickerDialog() -> some View {
    ForEach(model.availableSpaces) { userSpace in
      Button(userSpace.teamName) {
        Task {
          do {
            try await self.model.save(in: userSpace)
            await MainActor.run {
              self.action(.saved)
            }

            report?(
              UserEvent.ImportData(
                backupFileType: .dash, importDataStatus: .success, importDataStep: .success,
                importSource: .sourceDash, isDirectImport: false))
          } catch {
            await MainActor.run {
              self.action(.savingError)
            }
          }
        }
      }
    }

    Button(CoreL10n.cancel, role: .cancel) {
      showSpaceConfirmationDialog = false
    }
  }

  @ViewBuilder
  var importButtonBackground: some View {
    let colors = [
      Color.ds.background.alternate,
      Color.ds.background.alternate.opacity(0),
    ]
    LinearGradient(gradient: Gradient(colors: colors), startPoint: .bottom, endPoint: .top)
      .edgesIgnoringSafeArea(.bottom)
  }

  private func save() {
    Task {
      do {
        try await self.model.save(in: nil)
        await MainActor.run {
          self.action(.saved)
        }

        report?(
          UserEvent.ImportData(
            backupFileType: .dash, importDataStatus: .success, importDataStep: .success,
            importSource: .sourceDash, isDirectImport: false))
      } catch ImportViewModelError.needsSpaceSelection {
        self.showSpaceConfirmationDialog = true
      } catch {
        await MainActor.run {
          self.action(.savingError)
        }
      }
    }
  }

}

private struct ImportItemRowView: View {

  @ObservedObject
  var item: ImportItem

  let iconViewModel: VaultItemIconViewModel

  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      VaultItemIconView(isListStyle: true, model: iconViewModel)
        .padding(.trailing, 16)

      VStack(alignment: .leading) {
        Text(item.vaultItem?.localizedTitle ?? "")
          .font(.body.weight(.medium))
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .lineLimit(1)

        Spacer()
          .frame(height: 1)

        Text(item.vaultItem?.localizedSubtitle ?? "")
          .font(.footnote)
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .lineLimit(1)
      }
      .padding(.vertical, 10)

      Spacer()

      NativeCheckmarkIcon(isChecked: item.isSelected)
        .frame(width: 24, height: 24)
    }
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .onTapGesture {
      item.isSelected.toggle()
    }
    .fiberAccessibilityElement(children: .combine)
  }

}

#Preview {
  ImportListView(model: DashImportViewModel.mock) { _ in }
}
