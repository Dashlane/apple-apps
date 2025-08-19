import DesignSystem
import SwiftUI

public struct DetailList<Content: View, TitleAccessory: View>: View {

  let title: Text
  let titleAccessory: TitleAccessory
  let content: Content
  let collapseThreshold: Double = -20
  @Environment(\.detailListCollapseMode) var collapseMode
  @State private var shouldCollapseOnScroll: Bool = false
  private var isCollapsed: Bool {
    switch collapseMode {
    case .always:
      true
    case .onScroll:
      shouldCollapseOnScroll
    }
  }

  public init(
    title: Text,
    @ViewBuilder content: () -> Content,
    @ViewBuilder titleAccessory: () -> TitleAccessory
  ) {
    self.title = title
    self.content = content()
    self.titleAccessory = titleAccessory()
  }

  public var body: some View {
    GeometryReader { reader in
      List {
        titleSection(using: reader)

        content
          .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      }
      .listStyle(.ds.insetGrouped)
      #if !os(visionOS)
        .scrollDismissesKeyboard(.interactively)
      #endif
    }
    .navigationTitle(isCollapsed ? title : Text(""))
    .navigationBarTitleDisplayMode(.inline)
  }

  private func titleSection(using reader: GeometryProxy) -> some View {
    Section(header: title(using: reader)) {
      EmptyView()
    }
    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    .listSectionSpacing(collapseMode == .onScroll ? 16 : 0)
    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { scrollOffset in
      guard collapseMode == .onScroll else {
        return
      }

      withAnimation(.bouncy(extraBounce: 0.1)) {
        shouldCollapseOnScroll = scrollOffset < 10
      }
    }
  }

  @ViewBuilder
  private func title(using reader: GeometryProxy) -> some View {
    let isCollapsed = isCollapsed
    DetailTitleHeaderView(
      title: title,
      accessory: titleAccessory,
      isCollapsed: isCollapsed
    )
    .anchorPreference(key: ScrollOffsetPreferenceKey.self, value: .bottom) { anchor in
      reader[anchor].y.rounded()
    }
    .accessibilityHidden(isCollapsed)
    .visualEffect { visualEffect, _ in
      visualEffect
        .offset(y: isCollapsed ? collapseThreshold : 0)
    }
  }
}

struct DetailTitleHeaderView<Accessory: View>: View {
  let title: Text
  let accessory: Accessory
  let isCollapsed: Bool
  @Environment(\.detailListCollapseMode) var collapseMode

  var body: some View {
    let collapseMode = collapseMode
    VStack(spacing: 8) {
      if collapseMode == .onScroll {
        accessory
          .accessibilityHidden(true)
          .visualEffect { visualEffect, _ in
            visualEffect
              .scaleEffect(isCollapsed ? 0.3 : 1, anchor: .bottom)
          }
          .transition(
            .scale(0.5, anchor: .top)
              .combined(with: .offset(y: -40))
              .combined(with: .opacity)
              .animation(.bouncy(extraBounce: 0.1))
          )

        title
          .font(.system(size: 17).weight(.semibold))
          .multilineTextAlignment(.center)
          .lineLimit(2)
          .accessibilityAddTraits(.isHeader)
          .textCase(.none)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .visualEffect { visualEffect, _ in
            visualEffect
              .opacity(isCollapsed ? 0 : 1)
          }
          .transition(.offset(y: -60).combined(with: .opacity).animation(.snappy(duration: 0.2)))
      }
    }
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(title)
  }
}

public enum DetailListCollapseMode {
  case always
  case onScroll
}

extension EnvironmentValues {
  @Entry var detailListCollapseMode: DetailListCollapseMode = .onScroll
}

extension View {
  public func detailListCollapseMode(_ mode: DetailListCollapseMode) -> some View {
    self.environment(\.detailListCollapseMode, mode)
  }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
  typealias Value = CGFloat

  static var defaultValue: CGFloat = 0

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

#Preview("Centered Title + collapse on scroll") {
  NavigationView {
    DetailList(title: Text("A title")) {
      Section("A") {
        Text("1")
        Text("2")
        Text("3")
        Text("4")
        Text("5")
      }

      Section("B") {
        Text("1")
        Text("2")
        Text("3")
        Text("4")
        Text("5")
      }

      Section("C") {
        Text("1")
        Text("2")
        Text("3")
        Text("4")
        Text("5")
      }
    } titleAccessory: {
      Thumbnail.VaultItem.email
        .controlSize(.large)
    }

    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Edit") {

        }
      }
    }
    .detailListCollapseMode(.onScroll)
  }
}

#Preview("Awlays Collapsed") {
  NavigationView {
    DetailList(title: Text("A title")) {
      Section("A") {
        Text("1")
        Text("2")
        Text("3")
        Text("4")
        Text("5")
      }
    } titleAccessory: {
      Thumbnail.VaultItem.email
        .controlSize(.large)
    }

    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Edit") {

        }
      }
    }
    .detailListCollapseMode(.always)
  }

}
