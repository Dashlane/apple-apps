import SwiftUI
import DesignSystem
import CoreLocalization

struct SettingsLockSectionContent: View {

    @StateObject
    var viewModel: SettingsLockSectionViewModel

    init(viewModel: @autoclosure @escaping () -> SettingsLockSectionViewModel) {
        _viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        Picker(L10n.Localizable.kwAutoLockTime, selection: $viewModel.autoLockSelectedOption) {
            ForEach(SettingsLockSectionViewModel.AutoLockOption.allCases, id: \.self) { option in
                Text(option.text)
                    .tag(option)
            }
        }
        .foregroundColor(.ds.text.neutral.standard)
        .tint(.ds.text.neutral.quiet)
        .pickerStyle(.menu)

        DS.Toggle(L10n.Localizable.kwLockOnExit, isOn: $viewModel.isLockOnExitEnabled)
            .alert(isPresented: $viewModel.showBusinessEnforcedAlert) {
                Alert(title: Text(""),
                      message: Text(L10n.Localizable.kwLockOnExitForced),
                      dismissButton: .cancel(Text(CoreLocalization.L10n.Core.kwButtonOk), action: {
                    withAnimation { viewModel.isLockOnExitEnabled = true }
                }))
            }
            .onChange(of: viewModel.autoLockSelectedOption) { _ in
                viewModel.updateAutoLockTimeout()
            }
            .onChange(of: viewModel.isLockOnExitEnabled) { _ in
                viewModel.updateLockOnExitStatus()
            }
    }
}

extension SettingsLockSectionViewModel.AutoLockOption {

    private static let formatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .long
        formatter.unitOptions = .providedUnit
        return formatter
    }()

    var text: String {
        let measurement = Measurement(value: rawValue, unit: UnitDuration.seconds)

        switch self {
        case .never:
            return L10n.Localizable.kwNever.capitalized
        case .tenSeconds, .thirtySeconds:
            return Self.formatter.string(from: measurement)
        case .oneMinute, .fiveMinutes, .tenMinutes:
            return Self.formatter.string(from: measurement.converted(to: .minutes))
        }
    }
}

struct SettingsLockSectionContent_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SettingsLockSectionContent(viewModel: SettingsLockSectionViewModel.mock)
        }
    }
}
