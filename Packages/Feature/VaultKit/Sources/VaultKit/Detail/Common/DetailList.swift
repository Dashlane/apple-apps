import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

public struct DetailList<Content: View>: View {
  let content: Content
  let offsetEnabled: Bool
  @Binding
  var titleHeight: CGFloat?

  public init(
    offsetEnabled: Bool,
    titleHeight: Binding<CGFloat?>,
    @ViewBuilder content: () -> Content
  ) {
    self.content = content()
    self.offsetEnabled = offsetEnabled
    self._titleHeight = titleHeight
  }

  public var body: some View {
    GeometryReader { reader in
      List {
        offsetPlaceholder(using: reader)
          .accessibilityHidden(true)

        content
      }
      .detailListStyle()
      .background(Color.ds.background.alternate)
      .scrollContentBackground(.hidden)
      .scrollDismissesKeyboard(.interactively)
    }
  }

  private func offsetPlaceholder(using reader: GeometryProxy) -> some View {
    Section(header: offsetGetter(using: reader)) {
      EmptyView()
    }.onPreferenceChange(ScrollOffsetPreferenceKey.self) { scrollOffset in
      guard offsetEnabled else {
        return
      }
      self.titleHeight = max(scrollOffset + navigationBarMinHeight, navigationBarMinHeight)
    }
  }

  @ViewBuilder
  private func offsetGetter(using reader: GeometryProxy) -> some View {
    let base = Color.clear
    if offsetEnabled {
      base.anchorPreference(key: ScrollOffsetPreferenceKey.self, value: .bottom) { anchor in
        reader[anchor].y.rounded()
      }
      .padding(.bottom, DetailDimension.sectionMargin)
      .frame(height: DetailDimension.placeholderHeight)
    } else {
      base.frame(height: 1)
    }
  }
}

public struct DetailDimension {
  public static let placeholderHeight: CGFloat = 80
  public static let sectionMargin: CGFloat = 25
  public static let defaultNavigationBarHeight: CGFloat =
    placeholderHeight + navigationBarMinHeight + sectionMargin
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
  typealias Value = CGFloat

  static var defaultValue: CGFloat = 0

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

struct DetailList_Previews: PreviewProvider {
  struct TestingView: View {
    @State
    var titleHeight: CGFloat?

    var body: some View {
      DetailList(offsetEnabled: true, titleHeight: $titleHeight) {
        Section {
          if let height = titleHeight {
            Text("\(height)")
          } else {
            Text("no height")
          }
        }
      }
    }
  }

  static var previews: some View {
    TestingView()
  }
}
