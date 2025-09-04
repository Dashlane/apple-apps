import CoreLocalization
import SwiftUI

struct FieldDatePicker<Label: View>: View {
  @Binding var selection: Date?
  let range: DateFieldRange?
  @ViewBuilder let label: () -> Label
  @Environment(\.dismiss) var dismiss
  @Environment(\.dateFieldStyle) private var dateFieldStyle

  var pickerBindingSelection: Binding<Date> {
    Binding<Date>(
      get: {
        self.selection ?? Date.default(for: range)
      },
      set: { newValue in
        self.selection = newValue
      }
    )
  }

  var body: some View {
    main
      .labelsHidden()
      .tint(Color.ds.text.brand.standard)
      .datePickerStyle(.graphical)
  }

  @ViewBuilder
  var main: some View {
    switch dateFieldStyle {
    case .full:
      picker.datePickerStyle(.graphical)
    case .monthYear:
      picker.datePickerStyle(.monthYearWheels)
    }
  }

  @ViewBuilder
  var picker: some View {
    switch range {
    case .closed(let range):
      DatePicker(selection: pickerBindingSelection, in: range, displayedComponents: [.date]) {
        label()
      }
    case .from(let range):
      DatePicker(selection: pickerBindingSelection, in: range, displayedComponents: [.date]) {
        label()
      }
    case .through(let range):
      DatePicker(selection: pickerBindingSelection, in: range, displayedComponents: [.date]) {
        label()
      }
    case .none:
      DatePicker(selection: pickerBindingSelection, displayedComponents: [.date]) {
        label()
      }
    }
  }
}

#Preview {
  FieldDatePicker(selection: .constant(Date()), range: nil) {
    Text("Date")
  }
}

#Preview("Closed Range") {
  FieldDatePicker(
    selection: .constant(Date()), range: .closed(Date()...Date().addingTimeInterval(48 * 3600))
  ) {
    Text("Date")
  }
}

#Preview("From") {
  FieldDatePicker(selection: .constant(Date()), range: .from(Date()...)) {
    Text("Date")
  }
}

#Preview("Through") {
  FieldDatePicker(selection: .constant(Date()), range: .through(...Date())) {
    Text("Date")
  }
}
