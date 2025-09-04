import SwiftUI

public struct MonthYearWheelsDatePickerStyle: DatePickerStyle {
  public func makeBody(configuration: Configuration) -> some View {
    MonthYearPicker(configuration: configuration)
  }

  private struct MonthYearPicker: View {
    @Binding var date: Date

    let months: [String]
    let minDate: Date
    let maxDate: Date

    let calendar = Calendar.current

    @State private var selectedMonth: Int = 0
    @State private var selectedYear: Int = 0
    @State private var allowedYears: [Int] = []
    @State private var allowedMonths: Set<Int> = []

    init(configuration: Configuration) {
      _date = configuration.$selection

      let calendar = Calendar.current
      let currentYear = calendar.component(.year, from: Date())

      self.minDate =
        configuration.minimumDate ?? calendar.date(byAdding: .year, value: -100, to: Date())!
      self.maxDate =
        configuration.maximumDate ?? calendar.date(byAdding: .year, value: 100, to: Date())!

      self.months = calendar.monthSymbols

      let components = calendar.dateComponents([.month, .year], from: configuration.selection)
      _selectedMonth = State(initialValue: components.month ?? 1)
      _selectedYear = State(initialValue: components.year ?? currentYear)
    }

    var body: some View {
      HStack(spacing: 0) {
        monthPicker
        yearPicker
      }
      .pickerStyle(.wheel)
      .labelsHidden()
      .background {
        centerDecorator
      }
      .onChange(of: minDate, initial: true) { _, _ in
        allowedYears = computeAllowedYears()
      }
      .onChange(of: maxDate, initial: true) { _, _ in
        allowedYears = computeAllowedYears()
      }
      .onChange(of: selectedMonth, initial: true) { _, selectedMonth in
        date = makeDate(selectedMonth: selectedMonth, selectedYear: selectedYear) ?? date
      }
      .onChange(of: selectedYear, initial: true) { _, selectedYear in
        allowedMonths = computeAllowedMonthsForSelectedYear()

        if !allowedMonths.contains(selectedMonth) {
          selectedMonth = allowedMonths.sorted().first ?? 1
        }

        date = makeDate(selectedMonth: selectedMonth, selectedYear: selectedYear) ?? date
      }
    }

    private var monthPicker: some View {
      Picker("", selection: $selectedMonth) {
        ForEach(1...12, id: \.self) { month in
          let selectable = allowedMonths.contains(month)
          Text(months[month - 1])
            .tag(month)
            .foregroundColor(selectable ? .primary : .secondary)
            .selectionDisabled(!selectable)
        }
      }
    }

    private var yearPicker: some View {
      Picker("", selection: $selectedYear) {
        ForEach(allowedYears, id: \.self) { year in
          Text("\(year)")
            .tag(year)
        }
      }
    }

    private var centerDecorator: some View {
      Circle()
        .frame(width: 4, height: 4)
        .foregroundStyle(.secondary.opacity(0.2))
    }

    private func computeAllowedYears() -> [Int] {
      let minYear = calendar.component(.year, from: minDate)
      let maxYear = calendar.component(.year, from: maxDate)
      return Array(minYear...maxYear)
    }

    private func computeAllowedMonthsForSelectedYear() -> Set<Int> {
      var allowed = Set(1...12)
      let year = selectedYear
      if year == calendar.component(.year, from: minDate) {
        allowed = allowed.filter { $0 >= calendar.component(.month, from: minDate) }
      }
      if year == calendar.component(.year, from: maxDate) {
        allowed = allowed.filter { $0 <= calendar.component(.month, from: maxDate) }
      }
      return allowed
    }

    private func makeDate(selectedMonth: Int, selectedYear: Int) -> Date? {
      var components = calendar.dateComponents([.day, .hour, .minute, .second], from: date)
      components.month = selectedMonth
      components.year = selectedYear
      components.day = 1

      guard let newDate = calendar.date(from: components) else {
        return nil
      }

      return if newDate < minDate {
        minDate
      } else if newDate > maxDate {
        maxDate
      } else {
        newDate
      }
    }
  }
}

extension DatePickerStyle where Self == MonthYearWheelsDatePickerStyle {
  public static var monthYearWheels: MonthYearWheelsDatePickerStyle {
    return MonthYearWheelsDatePickerStyle()
  }
}

#Preview("Picker") {
  @Previewable @State var date: Date = .now
  VStack {
    Text(date, format: .dateTime.year().month())
    DatePicker(
      "Select a date",
      selection: $date,
      displayedComponents: [.date]
    )
    .datePickerStyle(.monthYearWheels)
  }

}
#Preview("Picker with range") {
  @Previewable @State var date: Date = .now
  VStack {
    Text(date, format: .dateTime.year().month())
    DatePicker(
      "Select a date", selection: $date,
      in: Date.now...,
      displayedComponents: [.date]
    )
    .datePickerStyle(.monthYearWheels)
  }
}
