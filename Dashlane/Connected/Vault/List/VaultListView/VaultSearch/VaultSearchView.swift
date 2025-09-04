import SwiftTreats
import SwiftUI
import VaultKit

struct VaultSearchView<InitialView: View>: View {
  let initialView: () -> InitialView

  @Environment(\.isSearching)
  private var isSearching

  @StateObject var model: VaultSearchViewModel

  init(
    model: @autoclosure @escaping () -> VaultSearchViewModel,
    initialView: @escaping () -> InitialView
  ) {
    self._model = .init(wrappedValue: model())
    self.initialView = initialView
  }

  var body: some View {
    VaultSearchSubview(
      model: model,
      initialView: initialView
    )
    .modifier(
      SearchModifier(
        searchCriteria: $model.searchCriteria,
        isPresented: $model.isSearchActive)
    )
    .autocorrectionDisabled()
    .onReceive(model.deeplinkPublisher) { deeplink in
      switch deeplink {
      case let .search(searchCriteria):
        self.model.displaySearch(for: searchCriteria)
      default: break
      }
    }
  }
}

private struct VaultSearchSubview<InitialView: View>: View {
  let initialView: InitialView

  @Environment(\.isSearching)
  private var isSearching

  @ObservedObject
  var model: VaultSearchViewModel

  @State
  private var isPresentingImportView = false

  init(
    model: VaultSearchViewModel,
    initialView: () -> InitialView
  ) {
    self.model = model
    self.initialView = initialView()
  }

  var body: some View {
    Group {
      if model.isSearchActive {
        VaultActiveSearchView(model: model.makeActiveSearchViewModel())
      } else {
        initialView
      }
    }
    .frame(maxHeight: .infinity)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        UserSpaceSwitcher(
          model: model.userSwitcherViewModelFactory.make(),
          displayTeamName: true
        )
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        addButton
      }
    }
    .iPhoneOnlyBackground()
    .mainMenuShortcut(.search) {
      model.isSearchActive = true
    }
    .onChange(of: isSearching) { _, newValue in
      self.model.isSearchActive = newValue
    }
    .sheet(
      isPresented: $isPresentingImportView,
      content: {
        ImportView(importSource: .vaultList)
      })
  }

  private var addButton: some View {
    AddVaultButton(
      isImportEnabled: true, category: nil,
      onAction: { action in
        switch action {
        case .add(let type):
          model.add(type: type)
        case .import:
          isPresentingImportView = true
        }
      }
    )
    .fiberAccessibilityLabel(Text(L10n.Localizable.accessibilityAddToVault))
    .fiberAccessibilityRemoveTraits(.isImage)
  }
}

extension View {
  @ViewBuilder
  fileprivate func iPhoneOnlyBackground() -> some View {
    if !Device.is(.pad, .mac, .vision) {
      self.background(Color.ds.background.default)
    } else {
      self
    }
  }
}

private struct SearchModifier: ViewModifier {

  @Binding var searchCriteria: String
  @Binding var isPresented: Bool

  private let placement: SearchFieldPlacement = .navigationBarDrawer(displayMode: .always)
  private let prompt = L10n.Localizable.itemsTabSearchPlaceholder

  func body(content: Content) -> some View {
    content
      .searchable(
        text: $searchCriteria,
        isPresented: $isPresented,
        placement: placement,
        prompt: prompt
      )
  }
}

struct VaultSearchView_Previews: PreviewProvider {
  static var previews: some View {
    VaultSearchView(
      model: .mock,
      initialView: {
        Text("list")
      })
  }
}
