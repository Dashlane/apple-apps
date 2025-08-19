import CoreLocalization
import SwiftUI

public struct DisplayField<Content: View, Actions: View>: View {
  private let actions: Actions
  private let content: Content
  private let label: String

  public init(
    _ label: String,
    @ViewBuilder content: () -> Content,
    @ViewBuilder actions: () -> Actions
  ) {
    self.label = label
    self.content = content()
    self.actions = actions()
  }

  public init(
    _ label: String,
    text: String,
    @ViewBuilder actions: () -> Actions
  ) where Content == Label<Text, EmptyView> {
    self.label = label
    self.content = Label(
      title: { Text(verbatim: text) },
      icon: { EmptyView() }
    )
    self.actions = actions()
  }

  public init(
    _ label: String,
    text: String
  ) where Content == Label<Text, EmptyView>, Actions == EmptyView {
    self.init(label, text: text) {
      EmptyView()
    }
  }

  public init(
    _ label: String,
    placeholder: String
  ) where Content == _DisplayFieldTextualPlaceholder, Actions == EmptyView {
    self.init(label) {
      _DisplayFieldTextualPlaceholder(placeholder)
    } actions: {
      EmptyView()
    }
  }

  public init(
    _ label: String,
    placeholder: String,
    @ViewBuilder actions: () -> Actions
  ) where Content == _DisplayFieldTextualPlaceholder {
    self.init(label) {
      _DisplayFieldTextualPlaceholder(placeholder)
    } actions: {
      actions()
    }
  }

  public var body: some View {
    DetailFieldContainer(label) {
      ViewThatFits {
        content
          .lineLimit(1)
        content
      }
      .geometryGroup()
      .labelStyle(.displayFieldGenericText)
    } actions: {
      actions
    }
  }
}

public struct _DisplayFieldTextualPlaceholder: View {
  private let text: String

  init(_ text: String) {
    self.text = text
  }

  public var body: some View {
    Text(verbatim: text)
      .foregroundStyle(Color.ds.text.oddity.disabled)
  }
}
