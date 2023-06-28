import SwiftUI
import CoreSession
import UIComponents
import DesignSystem
import UIDelight
import LoginKit
import CoreLocalization

struct DevicesList: View {

    @ObservedObject
    var model: DeviceListViewModel

    @State
    private var selectedDevice: BucketDevice?

    @State
    private var deviceToBeRenamed: BucketDevice?

    @State
    private var deletionRequest: DeletionRequest?

    @State
    private var selectedDevices = Set<String>()

    enum DeletionRequest: Identifiable {
        case singleItem(BucketDevice)
        case multipleItems([BucketDevice])

        var id: String {
            switch self {
            case .singleItem:
                return "single"
            case .multipleItems:
                return "multiple"
            }
        }
    }

    @Environment(\.editMode) var mode

    @ViewBuilder
    var body: some View {
        ZStack {
            Spacer()
                .alert(isPresented: self.$model.isDeactivationFailed, content: self.deactivateFailAlert) 
            list
                .fullScreenCover(item: self.$deviceToBeRenamed, content: self.renameView)
                .actionSheet(item: self.$selectedDevice, content: self.mainActionSheet)
                .alert(item: self.$deletionRequest, content: self.deactivateAlert)
                .toolbar(mode?.wrappedValue != .active ? .hidden : .visible, for: .bottomBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }

                    ToolbarItemGroup(placement: .bottomBar) {
                        bottomBar
                    }
                }

            if model.listStatus == .loading {
                loadingIndicator
            } else if model.listStatus == .noInternet {
                listErrorPlaceholder(withMessage: CoreLocalization.L10n.Core.kwNoInternet)
            } else if model.listStatus == .error {
                listErrorPlaceholder(withMessage: CoreLocalization.L10n.Core.kwExtSomethingWentWrong)
            }
        }.animation(.default, value: model.devicesGroups)
            .navigationBarBackButtonHidden(mode?.wrappedValue == .active)
    }

    @ViewBuilder
    var bottomBar: some View {
        Menu {
            Button(L10n.Localizable.kwDeviceListToolbarUnselectAll) {
                self.selectedDevices = []
            }
            .disabled(selectedDevices.isEmpty)
            Button(L10n.Localizable.kwDeviceListToolbarSelectOthers) {
                self.selectedDevices = model.allDevicesIdsButCurrentOne()
            }
            Button(L10n.Localizable.kwDeviceListToolbarSelectAll) {
                self.selectedDevices = model.allDevicesIds()
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        Spacer()
        Text(L10n.Localizable.kwDeviceListToolbarTitle).bold()
        Spacer()
        Button(action: {
            let devices = model.devices(forIds: self.selectedDevices)
            if devices.count == 1, let device = devices.first {
                self.deletionRequest = .singleItem(device)
            } else {
                self.deletionRequest = .multipleItems(devices)
            }
        }, label: {
            Image(systemName: "trash")
                .foregroundColor(.ds.text.danger.standard)
        }).disabled(self.selectedDevices.isEmpty)
    }

        var list: some View {
        List(selection: $selectedDevices) {
            ForEach(model.devicesGroups) { devices in
                LargeHeaderSection(title: devices.dateGroup.localizedDeviceTitle) {
                    ForEach(devices.devices) { device in
                        BucketDeviceRow(device: device, isCurrent: model.currentDeviceId == device.id )
                            .padding(6)
                                                                                                    .onTapGesture(enabled: mode?.wrappedValue != .active) {
                                self.selectedDevice = device
                            }

                    }
                }
            }

        }
        .navigationTitle(L10n.Localizable.kwDeviceListTitle)
        .reportPageAppearance(.settingsDeviceList)
    }

    private var loadingIndicator: some View {
        IndeterminateCircularProgress()
            .frame(width: 30, height: 30)
    }

    private func listErrorPlaceholder(withMessage message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
            Spacer()
            RoundedButton(L10n.Localizable.fetchFailTryAgain) {
                self.model.fetch()
            }
        }.padding()
    }

        private func mainActionSheet(for device: BucketDevice) -> ActionSheet {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let title =  Text(device.name)
            + Text("\n\(L10n.Localizable.kwDeviceLastActive): ")
            + Text("\(device.lastUpdateDate, formatter: formatter)")

        return ActionSheet(title: title,
                           buttons: [
                            .default(Text(CoreLocalization.L10n.Core.kwDeviceRename), action: {
                                self.deviceToBeRenamed = device
                            }),
                            .destructive(Text(L10n.Localizable.kwDeviceDeactivate), action: {
                                DispatchQueue.main.async {
                                    self.deletionRequest = .singleItem(device)
                                }
                            }),
                            .cancel()
                           ])
    }

    private func renameView(for device: BucketDevice) -> some View {
        DeviceRenameView(name: device.name) { completion in
            switch completion {
                case let .updated(name):
                    self.model.rename(device, with: name)
                    fallthrough
                case .cancel:
                    self.deviceToBeRenamed = nil
            }
        }
    }

    private func deactivateAlert(for mode: DeletionRequest) -> Alert {

        switch mode {
        case let .singleItem(device):
            return Alert(title: Text(L10n.Localizable.kwDeviceDeactivateTitleSingle),
                         message: Text(L10n.Localizable.kwDeviceDeactivateMessage),
                         primaryButton: .destructive(Text(L10n.Localizable.kwDeviceDeactivate), action: {
                self.model.deactivate([device])
                self.selectedDevice = nil
                self.selectedDevices = []
            }),
                         secondaryButton: .cancel())
        case let .multipleItems(devices):
            return Alert(title: Text(L10n.Localizable.kwDeviceDeactivateTitleMultiple(devices.count)),
                         message: Text(L10n.Localizable.kwDeviceDeactivateMessage),
                         primaryButton: .destructive(Text(L10n.Localizable.kwDeviceDeactivate), action: {
                self.model.deactivate(devices)
                self.selectedDevices = []
            }),
                         secondaryButton: .cancel())
        }

    }

    private func deactivateFailAlert() -> Alert {
        Alert(title: Text(L10n.Localizable.kwDeviceDeactivateFailureTitle),
              message: Text(L10n.Localizable.kwDeviceDeactivateFailureMsg))
    }
}

extension BucketDevice: Identifiable { }

struct DevicesListView_Previews: PreviewProvider {
    static let devices = [  BucketDevice(id: "current",
                                         name: "iPhone",
                                         platform: .iphone,
                                         creationDate: Date(),
                                         lastUpdateDate: Date(),
                                         lastActivityDate: Date().addingTimeInterval(-300),
                                         isBucketOwner: false,
                                         isTemporary: false),
                            BucketDevice(id: "idPixel",
                                         name: "Unsafe Device",
                                         platform: .android,
                                         creationDate: Date(),
                                         lastUpdateDate: Date(),
                                         lastActivityDate: Date().addingTimeInterval(-990000),
                                         isBucketOwner: false,
                                         isTemporary: false),
                            BucketDevice(id: "idWin",
                                         name: "Windobe",
                                         platform: .windows,
                                         creationDate: Date(),
                                         lastUpdateDate: Date(),
                                         lastActivityDate: Date().addingTimeInterval(-990000),
                                         isBucketOwner: false,
                                         isTemporary: false),
                            BucketDevice(id: "idWeb",
                                         name: "Slow Web",
                                         platform: .web,
                                         creationDate: Date(),
                                         lastUpdateDate: Date(),
                                         lastActivityDate: Date().addingTimeInterval(-1990000),
                                         isBucketOwner: false,
                                         isTemporary: false)
    ]

    static var previews: some View {
        Group {
            DevicesList(model: .init(deviceService: FakeDeviceService(listResult: .success(.init(devices: Set(devices)))), currentDeviceId: "current",
                                     reachability: NetworkReachability(isConnected: true)))

            DevicesList(model: .init(deviceService: FakeDeviceService(listResult: .failure(URLError(.unknown))), currentDeviceId: "current",
                                     reachability: NetworkReachability(isConnected: false)))

            DevicesList(model: .init(deviceService: FakeDeviceService(listResult: .success(.init(devices: Set(devices))), unlinkResult: .failure(URLError(.unknown))), currentDeviceId: "current",
                                     reachability: NetworkReachability(isConnected: true)))
        }

    }
}

private extension DateGroup {
    var localizedDeviceTitle: String {
        switch self {
            case .last24Hours:
                return L10n.Localizable.kwDeviceHeaderDay
            case .lastMonth:
                return L10n.Localizable.kwDeviceHeaderMonth
            case .lastYear:
                return L10n.Localizable.kwDeviceHeaderYear
            case .older:
                return L10n.Localizable.kwDeviceHeaderOlder
        }
    }
}
