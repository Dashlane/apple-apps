import SwiftUI

@available(
  *, deprecated,
  message:
    "Use #Preview instead. Dynamic type, orientation, color scheme, and device variants can be selected from Canvas settings"
)
public struct MultiContextPreview<Content: View>: View {

  public enum DeviceRange {
    case all
    case mainScreenSizes
    case some([Device])
    case none
  }

  public enum Device: String, Identifiable, CaseIterable {
    public var id: String { rawValue }

    case iPhoneSE = "iPhone SE (1st generation)"
    case iPhone8 = "iPhone 8"
    case iPhone8Plus = "iPhone 8 Plus"
    case iPhone11 = "iPhone 11"
    case iPhone11Pro = "iPhone 11 Pro"
    case iPhone11ProMax = "iPhone 11 Pro Max"
    case iPadPro = "iPad Pro (9.7-inch)"
  }

  private let previewDevices: [PreviewDevice]

  private let isDynamicTypePreviewEnabled: Bool

  private let addDefaultBackground: Bool

  private let content: Content

  public init(
    deviceRange: DeviceRange = .none,
    dynamicTypePreview: Bool = false,
    addDefaultBackground: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    switch deviceRange {
    case .none:
      self.previewDevices = []
    case .all:
      self.previewDevices = Device.allCases.map { PreviewDevice.init(rawValue: $0.rawValue) }
    case .mainScreenSizes:
      let devices: [Device] = [.iPhoneSE, .iPhone8, .iPhone11, .iPadPro]
      self.previewDevices = devices.map { PreviewDevice.init(rawValue: $0.rawValue) }
    case let .some(devices):
      self.previewDevices = devices.map { PreviewDevice.init(rawValue: $0.rawValue) }
    }

    self.isDynamicTypePreviewEnabled = dynamicTypePreview
    self.addDefaultBackground = addDefaultBackground
    self.content = content()
  }

  public var body: some View {
    Group {
      if previewDevices.isEmpty == false {
        ForEach(previewDevices) { device in
          self.contentPresentation(
            on: device, colorScheme: .light, withDynamicTypePreviews: isDynamicTypePreviewEnabled)
        }

        ForEach(previewDevices) { device in
          self.contentPresentation(
            on: device, colorScheme: .dark, withDynamicTypePreviews: isDynamicTypePreviewEnabled)
        }
      } else {
        self.contentPresentation(
          colorScheme: .light, withDynamicTypePreviews: isDynamicTypePreviewEnabled)
        self.contentPresentation(
          colorScheme: .dark, withDynamicTypePreviews: isDynamicTypePreviewEnabled)
      }
    }
  }

  private func contentPresentation(
    on device: PreviewDevice? = nil, colorScheme: ColorScheme, withDynamicTypePreviews: Bool
  ) -> some View {
    let content = self.content
      .environment(\.colorScheme, colorScheme)
      .previewDevice(device)
      .addDefaultBackgroundIfNeeded(addDefaultBackground, colorScheme: colorScheme)

    return Group {
      if withDynamicTypePreviews {
        content.environment(\.sizeCategory, .extraSmall).previewDisplayName(
          "\(device?.rawValue ?? "") \(colorScheme.name), XS")
        content.previewDisplayName("\(device?.rawValue ?? "") \(colorScheme.name), Default size")
        content.environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge).previewDisplayName(
          "\(device?.rawValue ?? "") \(colorScheme.name), XXXL")
      } else {
        content.previewDisplayName("\(device?.rawValue ?? "") \(colorScheme.name)")
      }
    }
  }
}

extension View {
  @ViewBuilder
  fileprivate func addDefaultBackgroundIfNeeded(_ needs: Bool, colorScheme: ColorScheme)
    -> some View
  {
    if needs {
      self.background(colorScheme == .light ? Color.white : Color.black)
    } else {
      self
    }
  }
}

extension PreviewDevice: Identifiable {
  public var id: String { rawValue }
}

extension ColorScheme {
  fileprivate var name: String {
    switch self {
    case .dark:
      return "Dark Mode"
    case .light:
      return "Light Mode"
    @unknown default:
      assertionFailure()
      return "Unknown color scheme"
    }
  }
}
