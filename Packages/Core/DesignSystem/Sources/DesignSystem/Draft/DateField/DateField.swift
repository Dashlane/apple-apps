import CoreLocalization
import Foundation
import SwiftUI
import UIDelight

extension DS.Draft {
  public struct DateField<Actions: View>: View {
    private let label: String
    @Binding private var date: Date?
    private let range: DateFieldRange?
    private let actions: Actions
    @State private var isEditing: Bool = false
    @Environment(\.fieldEditionDisabled) private var fieldEditionDisabled
    @Environment(\.defaultFieldActionsHidden) private var defaultFieldActionsHidden
    @Environment(\.fieldDisabledEditionAppearance) private var fieldDisabledEditionAppearance

    @Environment(\.dateFieldStyle) private var dateFieldStyle
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.isEnabled) private var isEnabled

    public var body: some View {
      DetailFieldContainer(label) {
        labelContent
      } actions: {
        if !defaultFieldActionsHidden
          && !(fieldEditionDisabled && fieldDisabledEditionAppearance == .discrete)
        {
          DS.FieldAction.Button(
            CoreL10n.datePickerCalendar, image: .ds.calendar.outlined, action: edit
          )
          .padding(.vertical, 2)
          .style(intensity: isEditing && horizontalSizeClass == .regular ? .quiet : .supershy)
          .popover(isPresented: $isEditing, content: editionView)
          .animation(.default, value: isEditing)
          .disabled(fieldEditionDisabled)
        }

        actions
      }
      .contentShape(Rectangle())
      .environment(\.displayLabelAsOverlay, date == nil)
      .environment(\.isFieldEditing, isEditing)
      .onTapGesture(perform: edit)
    }

    var labelContent: some View {
      VStack {
        if let date = date {
          Label {
            Text(date, format: dateFieldStyle)
          } icon: {

          }
          .labelStyle(.fieldContent)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func editionView() -> some View {
      Group {
        if horizontalSizeClass == .compact {
          datePicker
            .frame(maxHeight: .infinity)
            .overlay(alignment: .topLeading) {
              pickerToolbar
            }
            .padding(.top, 32)
        } else {
          datePicker
            .padding(16)
        }
      }
      .presentationCompactAdaptation(.sheet)
      .presentationDetents([PresentationDetent.medium])
    }

    var datePicker: some View {
      FieldDatePicker(selection: $date, range: range) {
        EmptyView()
      }
      .frame(width: 320)
    }

    @ViewBuilder
    var pickerToolbar: some View {
      HStack {
        Spacer()

        Button(CoreL10n.kwDoneButton) {
          isEditing = false
        }
        .buttonStyle(.borderless)
      }
      .padding(.horizontal, 4)

    }

    func edit() {
      guard !fieldEditionDisabled && isEnabled else {
        return
      }
      withAnimation {
        if date == nil {
          date = .default(for: range)
        }

        isEditing = true
      }
    }
  }
}

extension DS.Draft.DateField {
  public init(
    _ label: String,
    date: Binding<Date?>,
    in range: DateFieldRange? = nil,
    @ViewBuilder actions: () -> Actions
  ) {
    self.label = label
    self._date = date
    self.range = range
    self.actions = actions()
  }

  public init(
    _ label: String,
    date: Binding<Date?>,
    in range: PartialRangeThrough<Date>,
    @ViewBuilder actions: () -> Actions
  ) {
    self.label = label
    self._date = date
    self.range = .through(range)
    self.actions = actions()
  }

  public init(
    _ label: String,
    date: Binding<Date?>,
    in range: PartialRangeFrom<Date>,
    @ViewBuilder actions: () -> Actions
  ) {
    self.label = label
    self._date = date
    self.range = .from(range)
    self.actions = actions()
  }

  public init(
    _ label: String,
    date: Binding<Date?>,
    in range: ClosedRange<Date>,
    @ViewBuilder actions: () -> Actions
  ) {
    self.label = label
    self._date = date
    self.range = .closed(range)
    self.actions = actions()
  }
}

public enum DateFieldStyle {
  case full
  case monthYear
}

extension DateFieldStyle: FormatStyle {
  public func format(_ value: Date) -> String {
    switch self {
    case .full:
      return value.formatted(
        .dateTime.day(.defaultDigits).month(.defaultDigits).year(.defaultDigits))
    case .monthYear:
      return value.formatted(.dateTime.month(.defaultDigits).year(.defaultDigits))
    }
  }
}

extension EnvironmentValues {
  @Entry var dateFieldStyle: DateFieldStyle = .full
}

extension View {
  public func dateFieldStyle(_ style: DateFieldStyle) -> some View {
    environment(\.dateFieldStyle, style)
  }
}

#Preview {
  @Previewable @State var date: Date? = Date()
  @Previewable @State var emptyDate: Date?
  @Previewable @State var disabledDate: Date? = Date()
  @Previewable @State var disabledEmphasizedDate: Date? = Date()
  @Previewable @State var monthYearDate: Date? = Date()

  List {
    DS.Draft.DateField("Date already set", date: $date, in: .future) {

    }
    DS.Draft.DateField("Date not set", date: $emptyDate, in: .past) {

    }

    DS.Draft.DateField("Disabled ", date: $disabledDate, in: .past) {

    }
    .fieldEditionDisabled(true, appearance: .discrete)

    DS.Draft.DateField("Disabled Emphasized", date: $disabledEmphasizedDate, in: .past) {

    }
    .fieldEditionDisabled(true, appearance: .emphasized)

    DS.Draft.DateField("Date month year", date: $monthYearDate, in: .past) {

    }
    .dateFieldStyle(.monthYear)

  }.listStyle(.ds.insetGrouped)
}
