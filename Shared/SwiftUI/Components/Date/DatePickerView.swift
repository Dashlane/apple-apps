import SwiftUI
import SwiftTreats

struct DatePickerView: View {
    @Binding
    var date: Date?

    let dateFormatter: DateFormatter
    let maximumDate: Date?
    let minimumDate: Date?
    let mode: FiberDatePickerMode

    @State var presented = false
    
    init(_ date: Binding<Date?>,
         dateFormatter: DateFormatter,
         mode: FiberDatePickerMode,
         maximumDate: Date? = nil,
         minimumDate: Date? = nil) {
        self._date = date
        self.dateFormatter = dateFormatter
        self.mode = mode
        self.maximumDate = maximumDate
        self.minimumDate = minimumDate
    }
    
    var body: some View {
        if Device.isMac {
           textualPickerView
        } else {
            FiberKeyboardDatePicker($date,
                                    dateFormatter: dateFormatter,
                                    mode: mode,
                                    maximumDate: maximumDate,
                                    minimumDate: minimumDate)
        }
    }
    
    @ViewBuilder
    private var textualPickerView: some View {
        ZStack {
            HStack {
                if let date = date {
                    Text(dateFormatter.string(from: date))
                } else {
                    Text("")
                }
                Spacer()
            }
            
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .fullScreenCover(isPresented: $presented) {
            modalPickerView
        }
        .onTapGesture {
            self.presented = true
        }
    }
    
    @ViewBuilder
    private var modalPickerView: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { self.presented = false }, label: {
                        Text(L10n.Localizable.kwDoneButton).bold()
                    })
                }
                .padding([.top, .trailing])
                FiberInlineDatePicker($date,
                                      dateFormatter: dateFormatter,
                                      mode: mode,
                                      maximumDate: maximumDate,
                                      minimumDate: minimumDate)
            }
            .frame(width: 320)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DatePickerView_Previews: PreviewProvider {
    static let date = Date()
    static var previews: some View {
        DatePickerView(.constant(date),
                       dateFormatter: .birthDateFormatter,
                       mode: .monthAndYear)
    }
}
