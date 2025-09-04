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
    isCurrent ? CoreL10n.kwDeviceCurrentDevice : device.displayedDate
  }

  public var body: some View {
    HStack(spacing: 12) {
      Image(platform: device.platform)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 40)
        .foregroundStyle(Color.ds.text.brand.quiet)
        .fiberAccessibilityHidden(true)
      VStack(alignment: .leading) {
        Text(device.name)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .font(.headline)
          .lineLimit(2)

        Text(subtitle)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .font(.caption)

      }
      .minimumScaleFactor(0.8)
      .lineLimit(1)
      .truncationMode(.tail)
    }
  }
}

#Preview("Android Device", traits: .sizeThatFitsLayout) {
  BucketDeviceRow(
    device: BucketDevice(
      id: "id",
      name: "Galaxy S8+",
      platform: .android,
      creationDate: Date(),
      lastUpdateDate: Date(),
      lastActivityDate: Date().addingTimeInterval(-300),
      isBucketOwner: false,
      isTemporary: false
    )
  )
  .background(.ds.background.default)
}

#Preview("iPad Device", traits: .sizeThatFitsLayout) {
  BucketDeviceRow(
    device: BucketDevice(
      id: "id",
      name: "iPad Pro (12.9-inch) (6th generation) (16 GB)",
      platform: .ipad,
      creationDate: Date(),
      lastUpdateDate: Date(),
      lastActivityDate: Date().addingTimeInterval(-500),
      isBucketOwner: false,
      isTemporary: false
    )
  )
  .background(.ds.background.default)
}

#Preview("iPad Device - Long Name", traits: .sizeThatFitsLayout) {
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
      isTemporary: false
    )
  )
  .background(.ds.background.default)
}
