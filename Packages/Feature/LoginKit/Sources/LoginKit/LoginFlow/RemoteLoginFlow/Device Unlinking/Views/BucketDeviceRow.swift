import SwiftUI
import CoreSession
import UIDelight
import CoreLocalization
import DesignSystem

public struct BucketDeviceRow: View {

    let device: BucketDevice
    let isCurrent: Bool

    public init(device: BucketDevice,
                isCurrent: Bool = false) {
        self.device = device
        self.isCurrent = isCurrent
    }

    var subtitle: String {
        isCurrent ? L10n.Core.kwDeviceCurrentDevice : device.displayedDate
    }

    public var body: some View {
        HStack(spacing: 12) {
            device.platform.imageAsset.swiftUIImage
                .frame(width: 40)
                .foregroundColor(.secondary)
                .fiberAccessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(device.displayedName)
                    .id(device.displayedName)
                    .foregroundColor(.ds.text.neutral.catchy)
                    .font(.headline)

                Text(subtitle)
                    .foregroundColor(.ds.text.neutral.standard)
                    .font(.caption)

            }.minimumScaleFactor(0.8)
            .lineLimit(1)
            .truncationMode(.tail)
        }
    }
}

struct BucketDeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            BucketDeviceRow(device: BucketDevice(id: "id",
                                                   name: "iPhone",
                                                   platform: .iphone,
                                                   creationDate: Date(),
                                                   lastUpdateDate: Date(),
                                                   lastActivityDate: Date().addingTimeInterval(-300),
                                                   isBucketOwner: false,
                                                   isTemporary: false))
                .background(.ds.background.default)
        }
        .previewLayout(.sizeThatFits)

    }
}
