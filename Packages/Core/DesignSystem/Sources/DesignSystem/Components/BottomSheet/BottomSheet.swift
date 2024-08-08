#if canImport(UIKit)
  import SwiftUI
  import UIKit
  import UIDelight

  public struct BottomSheet<S: StringProtocol, Header: View, Actions: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @ScaledMetric private var cornerRadius = 16
    private let horizontalContentPadding = 24.0
    private let topContentPadding = 40.0
    private let bottomContentPadding = 32.0

    @State private var contentHeight: CGFloat?

    private let header: Header
    private let title: S
    private let description: S?
    private let actions: Actions

    public init(
      _ title: S,
      description: S? = nil,
      @ViewBuilder actions: @escaping () -> Actions,
      @ViewBuilder header: @escaping () -> Header
    ) {
      self.title = title
      self.description = description
      self.actions = actions()
      self.header = header()
    }

    public init(
      _ title: S,
      description: S? = nil,
      @ViewBuilder actions: @escaping () -> Actions
    ) where Header == EmptyView {
      self.title = title
      self.description = description
      self.actions = actions()
      self.header = EmptyView()
    }

    public var body: some View {
      VStack(spacing: 40) {
        header
          .accessibilityHidden(true)
        VStack(spacing: 8) {
          Text(title)
            .textStyle(.title.section.medium)
            .lineLimit(nil)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
          if let description {
            Text(description)
              .textStyle(.body.standard.regular)
              .lineLimit(nil)
              .foregroundStyle(Color.ds.text.neutral.standard)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .fixedSize(horizontal: false, vertical: true)
        VStack(spacing: 8) {
          actions
        }
      }
      .padding(.horizontal, horizontalContentPadding)
      .padding(.top, topContentPadding)
      .padding(.bottom, bottomContentPadding)
      .overlay(
        GeometryReader { proxy in
          Color.clear
            .preference(key: HeightPreferenceKey.self, value: proxy.size.height)
        }
        .frame(maxHeight: contentHeight)
      )
      .onPreferenceChange(HeightPreferenceKey.self) { height in
        contentHeight = height
      }
      .presentationBackground(Color.ds.container.agnostic.neutral.supershy)
      .presentationDetents(contentHeight.flatMap({ [.height($0)] }) ?? [])
      .presentationCornerRadius(cornerRadius)
    }
  }

  private struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat?
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
      value = nextValue()
    }
  }

  extension View {

    @_disfavoredOverload
    @ViewBuilder
    fileprivate func presentationBackground(_ style: some ShapeStyle) -> some View {
      if #available(iOS 16.4, *) {
        presentationBackground(style)
      } else {
        self
      }
    }

    @_disfavoredOverload
    @ViewBuilder
    fileprivate func presentationCornerRadius(_ cornerRadius: CGFloat?) -> some View {
      if #available(iOS 16.4, *) {
        presentationCornerRadius(cornerRadius)
      } else {
        self
      }
    }
  }

  struct BottomSheet_Previews: PreviewProvider {
    static var previews: some View {
      BottomSheetPreview()
    }
  }
#endif
