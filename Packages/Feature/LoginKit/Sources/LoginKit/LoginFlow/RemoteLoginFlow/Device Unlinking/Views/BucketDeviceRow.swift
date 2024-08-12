import CoreLocalization
import CoreSession
import DesignSystem
import SwiftUI
import UIDelight

public struct BucketDeviceRow: View {

  let device: BucketDevice
  let isCurrent: Bool

  public init(
    device: BucketDevice,
    isCurrent: Bool = false
  ) {
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
        Text(device.name)
          .foregroundColor(.ds.text.neutral.catchy)
          .font(.headline)
          .lineLimit(2)

        Text(subtitle)
          .foregroundColor(.ds.text.neutral.standard)
          .font(.caption)

      }
      .minimumScaleFactor(0.8)
      .lineLimit(1)
      .truncationMode(.tail)
    }
  }
}

struct BucketDeviceRow_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      VStack(alignment: .leading) {
        BucketDeviceRow(
          device: BucketDevice(
            id: "id",
            name: "Galaxy S8+",
            platform: .android,
            creationDate: Date(),
            lastUpdateDate: Date(),
            lastActivityDate: Date().addingTimeInterval(-300),
            isBucketOwner: false,
            isTemporary: false)
        )
        .background(.ds.background.default)
        BucketDeviceRow(
          device: BucketDevice(
            id: "id",
            name: "iPad Pro (12.9-inch) (6th generation) (16 GB)",
            platform: .ipad,
            creationDate: Date(),
            lastUpdateDate: Date(),
            lastActivityDate: Date().addingTimeInterval(-500),
            isBucketOwner: false,
            isTemporary: false)
        )
        .background(.ds.background.default)
        BucketDeviceRow(
          device: BucketDevice(
            id: "id",
            name:
              "Copy of iPad Pro (12.9-inch) (6th generation) (16GB) device of someone with a very long name",
            platform: .ipad,
            creationDate: Date(),
            lastUpdateDate: Date(),
            lastActivityDate: Date().addingTimeInterval(-5000),
            isBucketOwner: false,
            isTemporary: false)
        )
        .background(.ds.background.default)
      }
    }
    .previewLayout(.sizeThatFits)

  }
}
