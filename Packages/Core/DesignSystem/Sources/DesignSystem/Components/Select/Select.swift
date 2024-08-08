import CoreLocalization
import Foundation
import SwiftUI

private struct SelectionRow<Content: View, Value: Hashable>: View {
  @Environment(\.dismiss) private var dismiss

  private let content: Content
  private let selectedValue: Binding<Value?>
  private let value: Value?

  init(
    selectedValue: Binding<Value?>,
    value: SelectOptionValueTraitKey<Value>.Value,
    @ViewBuilder _ content: () -> Content
  ) {
    self.content = content()
    self.selectedValue = selectedValue
    self.value =
      switch value {
      case let .tagged(option):
        option
      case .untagged:
        nil
      }
  }

  var body: some View {
    Button(
      action: {
        selectedValue.wrappedValue = value
        dismiss()
      },
      label: {
        HStack {
          content
            .tint(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
          if isSelected {
            Image(systemName: "checkmark")
              .foregroundStyle(Color.accentColor)
              .font(.body.weight(.semibold))
              .accessibilityHidden(true)
          }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
      }
    )
  }

  private var isSelected: Bool {
    return value == selectedValue.wrappedValue
  }
}

private struct SelectOptionsDestructuring<Value: Hashable>: _VariadicView.MultiViewRoot {
  private let selectedValue: Binding<Value?>
  private let unspecifiedValueOptionLabel: String?

  init(
    selectedValue: Binding<Value?>,
    unspecifiedValueOptionLabel: String?
  ) {
    self.selectedValue = selectedValue
    self.unspecifiedValueOptionLabel = unspecifiedValueOptionLabel
  }

  @ViewBuilder
  func body(children: _VariadicView.Children) -> some View {
    if let unspecifiedValueOptionLabel {
      Section {
        SelectionRow(selectedValue: selectedValue, value: .untagged) {
          Text(unspecifiedValueOptionLabel)
        }
      }
    }
    Section {
      ForEach(children) { child in
        SelectionRow(
          selectedValue: selectedValue,
          value: child[SelectOptionValueTraitKey<Value>.self]
        ) {
          child
        }
      }
    }
  }
}

public struct Select<SelectionValue: Hashable, Content: View>: View {
  private let contentProvider: (SelectionValue) -> Content
  private let label: String
  private let selection: Binding<SelectionValue?>
  private let textualRepresentationProperty: KeyPath<SelectionValue, String>
  private let unspecifiedValueOptionLabel: String?
  private let unspecifiedValueSelectionEnabled: Bool
  private let values: [SelectionValue]

  public init(
    _ label: String,
    values: [SelectionValue],
    selection: Binding<SelectionValue?>,
    textualRepresentation: KeyPath<SelectionValue, String>,
    unspecifiedValueOptionLabel: String? = nil,
    @ViewBuilder content: @escaping (SelectionValue) -> Content
  ) {
    self.label = label
    self.selection = selection
    self.contentProvider = content
    self.textualRepresentationProperty = textualRepresentation
    self.unspecifiedValueSelectionEnabled = true
    self.unspecifiedValueOptionLabel = unspecifiedValueOptionLabel
    self.values = values
  }

  public init(
    _ label: String,
    values: [SelectionValue],
    selection: Binding<SelectionValue?>,
    unspecifiedValueOptionLabel: String? = nil,
    @ViewBuilder content: @escaping (SelectionValue) -> Content
  ) where SelectionValue == String {
    self.init(
      label,
      values: values,
      selection: selection,
      textualRepresentation: \.self,
      unspecifiedValueOptionLabel: unspecifiedValueOptionLabel,
      content: content
    )
  }

  @_disfavoredOverload
  public init(
    _ label: String,
    values: [SelectionValue],
    selection: Binding<SelectionValue>,
    textualRepresentation: KeyPath<SelectionValue, String>,
    @ViewBuilder content: @escaping (SelectionValue) -> Content
  ) {
    self.label = label
    self.contentProvider = content
    self.selection = Binding(
      get: {
        selection.wrappedValue
      },
      set: { value in
        guard let value else { return }
        selection.wrappedValue = value
      }
    )
    self.textualRepresentationProperty = textualRepresentation
    self.unspecifiedValueSelectionEnabled = false
    self.unspecifiedValueOptionLabel = nil
    self.values = values
  }

  @_disfavoredOverload
  public init(
    _ label: String,
    values: [SelectionValue],
    selection: Binding<SelectionValue>,
    @ViewBuilder content: @escaping (SelectionValue) -> Content
  ) where SelectionValue == String {
    self.label = label
    self.contentProvider = content
    self.selection = Binding(
      get: {
        selection.wrappedValue
      },
      set: { value in
        guard let value else { return }
        selection.wrappedValue = value
      }
    )
    self.textualRepresentationProperty = \.self
    self.unspecifiedValueSelectionEnabled = false
    self.unspecifiedValueOptionLabel = nil
    self.values = values
  }

  public var body: some View {
    NavigationLink {
      List {
        _VariadicView.Tree(
          SelectOptionsDestructuring(
            selectedValue: selection,
            unspecifiedValueOptionLabel: unspecifiedValueOptionLabel
          )
        ) {
          ForEach(values, id: \.self) { value in
            contentProvider(value)
              .option(value)
          }
        }
      }
      .listAppearance(.insetGrouped)
      .navigationTitle(label)
      #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
      #endif
    } label: {
      DS.TextField(label, text: .constant(effectiveValueLabel))
        .fieldAppearance(.grouped)
        .editionDisabled(appearance: .discrete)
    }
    .accessibilityLabel(
      Text([label, effectiveValueLabel].filter(\.isNotEmpty).joined(separator: ", "))
    )
  }

  private var effectiveValueLabel: String {
    if let selectedValue = selection.wrappedValue {
      return selectedValue[keyPath: textualRepresentationProperty]
    }
    return unspecifiedValueOptionLabel ?? ""
  }
}

extension String {
  fileprivate var isNotEmpty: Bool {
    !isEmpty
  }
}

private struct SelectOptionValueTraitKey<V: Hashable>: _ViewTraitKey {
  enum Value {
    case untagged
    case tagged(V)
  }

  static var defaultValue: SelectOptionValueTraitKey<V>.Value {
    .untagged
  }
}

extension View {
  fileprivate func option<V: Hashable>(_ tag: V) -> some View {
    _trait(SelectOptionValueTraitKey<V>.self, .tagged(tag))
  }
}

private struct PreviewContent: View {
  enum Country: String, Identifiable, Hashable, CaseIterable {
    case england = "England"
    case france = "France"
    case spain = "Spain"

    var id: Self {
      self
    }
  }

  @State private var selection = "Ulrich"
  @State private var country: Country?
  @State private var preferredCountry: Country?

  private let names = [
    "Jonas",
    "Martha",
    "Mikkel",
    "Ulrich",
    "Katharina",
    "Charlotte",
    "Bartosz",
    "Magnus",
    "Franziska",
    "Peter",
    "Regina",
    "Aleksander",
    "Claudia",
    "Helge",
    "Ines",
    "Egon",
    "Noah",
  ]

  var body: some View {
    NavigationStack {
      List {
        Select("Name", values: names, selection: $selection) { name in
          Text(name)
        }
        Select(
          "Country",
          values: Country.allCases,
          selection: $country,
          textualRepresentation: \.rawValue
        ) { country in
          Text(country.rawValue)
        }
        Select(
          "Preferred Country",
          values: Country.allCases,
          selection: $preferredCountry,
          textualRepresentation: \.rawValue,
          unspecifiedValueOptionLabel: "Unspecified"
        ) { country in
          Text(country.rawValue)
        }
      }
      .navigationTitle("Custom")
      .listAppearance(.insetGrouped)
    }
  }
}

#Preview {
  PreviewContent()
}
