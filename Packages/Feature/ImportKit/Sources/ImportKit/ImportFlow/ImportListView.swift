import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

public struct ImportListView<Model>: View where Model: ObservableObject, Model: ImportViewModel {

  public enum Action {
    case saved
    case savingError
  }

  @ObservedObject
  var model: Model

  var items: [VaultItem] {
    model.items.compactMap(\.vaultItem)
  }

  @ScaledMetric private var titleFontSize: CGFloat = 28

  let action: @MainActor (Action) -> Void
  @State var showSpaceConfirmationDialog = false

  public var body: some View {
    VStack {
      title
      passwordList
    }
    .confirmationDialog(
      L10n.Core.teamSpacesSharingAcceptPrompt,
      isPresented: $showSpaceConfirmationDialog,
      titleVisibility: .visible,
      actions: spacePickerDialog
    )
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    .navigationBarStyle(.transparent(tintColor: .ds.text.brand.standard, titleColor: nil))
    .overlay(importButton, alignment: .bottom)
    .reportPageAppearance(.importCsvPreviewDataUpload)
  }

  @ViewBuilder
  private var title: some View {
    if !items.isEmpty {
      Text(L10n.Core.m2WImportGenericImportScreenPrimaryTitle(model.items.count))
        .frame(maxWidth: 400, alignment: .leading)
        .font(DashlaneFont.custom(titleFontSize, .medium).font)
        .foregroundColor(.ds.text.neutral.catchy)
        .multilineTextAlignment(.leading)
        .padding(.horizontal, 16)
    } else {
      Text(L10n.Core.importLoadingItems)
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
        Text(L10n.Core.m2WImportGenericImportScreenImport)
          .fixedSize(horizontal: false, vertical: true)
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
          } catch {
            await MainActor.run {
              self.action(.savingError)
            }
          }
        }
      }
    }

    Button(L10n.Core.cancel, role: .cancel) {
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
          .foregroundColor(.ds.text.neutral.catchy)
          .lineLimit(1)

        Spacer()
          .frame(height: 1)

        Text(item.vaultItem?.localizedSubtitle ?? "")
          .font(.footnote)
          .foregroundColor(.ds.text.neutral.quiet)
          .lineLimit(1)
      }
      .padding(.vertical, 10)

      Spacer()

      if item.isSelected {
        Image(asset: Asset.checkboxSelected)
          .resizable()
          .frame(width: 24, height: 24)
      } else {
        Image(asset: Asset.checkboxUnselected)
          .resizable()
          .frame(width: 24, height: 24)
      }
    }
    .background(.ds.background.alternate)
    .onTapGesture {
      item.isSelected.toggle()
    }
    .fiberAccessibilityElement(children: .combine)
  }

}

struct ImportListView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(deviceRange: .some([.iPhone8, .iPhone11, .iPadPro])) {
      ImportListView(model: DashImportViewModel.mock, action: { _ in })
    }
  }
}
