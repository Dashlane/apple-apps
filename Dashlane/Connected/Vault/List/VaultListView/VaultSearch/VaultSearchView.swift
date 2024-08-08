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
    .onChange(of: isSearching) { newValue in
      self.model.isSearchActive = newValue
    }
  }

  private var addButton: some View {
    AddVaultButton(
      category: .none,
      onTap: model.onAddItemDropdown
    ) { model.add(type: $0) }
    .fiberAccessibilityLabel(Text(L10n.Localizable.accessibilityAddToVault))
    .fiberAccessibilityRemoveTraits(.isImage)
  }
}

extension View {
  fileprivate func searchActive(_ isActive: Bool) -> some View {
    overlay(
      SearchBarIntrospectController(isActive: isActive)
        .frame(width: 0, height: 0)
    )
  }

  @ViewBuilder
  fileprivate func iPhoneOnlyBackground() -> some View {
    if !Device.isIpadOrMac {
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
    if #available(iOS 17, *) {
      content
        .searchable(
          text: $searchCriteria,
          isPresented: $isPresented,
          placement: placement,
          prompt: prompt
        )
    } else {
      content
        .searchable(
          text: $searchCriteria,
          placement: placement,
          prompt: prompt

        )
        .searchActive(isPresented)
    }
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
