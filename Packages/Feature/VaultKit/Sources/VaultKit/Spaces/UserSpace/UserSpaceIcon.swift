import CoreLocalization
import CorePremium
import DashlaneAPI
import DesignSystem
import SwiftUI
import UIDelight

public struct UserSpaceIcon: View, Equatable {
  public enum Size: Equatable {
    case small
    case normal
    case large
  }

  let space: UserSpace
  let size: Size

  public init(space: UserSpace, size: Size) {
    self.space = space
    self.size = size
  }

  public var body: some View {
    switch space {
    case .both:
      size
        .allSpaceImage
        .foregroundColor(.ds.text.brand.standard)

    case .personal:
      UserSpaceLetterIcon(
        color: Asset.personalSpaceIconColor.swiftUIColor,
        title: L10n.Core.teamSpacesPersonalSpaceInitial,
        size: size
      )

    case let .team(team):
      UserSpaceLetterIcon(
        color: team.teamInfo.uiColor,
        title: team.teamInfo.letter ?? "",
        size: size
      )
    }
  }
}

extension PremiumStatusTeamInfo {
  var uiColor: Color {
    guard let hex = color, let color = Color(hex: hex) else {
      return .ds.text.brand.standard
    }
    return color
  }
}

private struct UserSpaceLetterIcon: View {
  let color: Color
  let title: String
  let size: UserSpaceIcon.Size

  @Environment(\.colorScheme)
  var colorScheme

  var body: some View {
    ZStack {
      if size == .small {
        size.outlineImage
          .foregroundColor(color)
      } else {
        size.backgroundImage
          .foregroundColor(color)

        if colorScheme == .dark {
          size.outlineImage
            .foregroundColor(Color(white: 1, opacity: 0.7))
        }
      }

      Text(title)
        .font(.system(size: size.fontSize, weight: .bold, design: .monospaced))
        .foregroundColor(size == .small ? color : .white)
    }
    .id(title)
  }
}

extension UserSpaceIcon.Size {
  var fontSize: CGFloat {
    switch self {
    case .small:
      return 8
    case .normal:
      return 14
    case .large:
      return 34
    }
  }

  var allSpaceImage: Image {
    Image(asset: Asset.allSpaces)
  }

  var backgroundImage: Image {
    switch self {
    case .small:
      return Image(asset: Asset.teamSpaceSmall)
    case .normal:
      return Image(asset: Asset.teamSpace)
    case .large:
      return Image(asset: Asset.teamSpaceLarge)
    }
  }

  var outlineImage: Image {
    switch self {
    case .small:
      return Image(asset: Asset.teamSpaceOutlineSmall)
    case .normal:
      return Image(asset: Asset.teamSpaceOutline)
    case .large:
      return Image(asset: Asset.teamSpaceOutlineLarge)
    }
  }
}

struct TeamSpaceView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      Group {
        HStack {
          UserSpaceIcon(space: .both, size: .small)
          UserSpaceIcon(space: .both, size: .normal)
          UserSpaceIcon(space: .both, size: .large)
        }

        HStack {
          UserSpaceIcon(space: .personal, size: .small)
          UserSpaceIcon(space: .personal, size: .normal)
          UserSpaceIcon(space: .personal, size: .large)
        }

        HStack {
          UserSpaceIcon(space: .team(.mock), size: .small)
          UserSpaceIcon(space: .team(.mock), size: .normal)
          UserSpaceIcon(space: .team(.mock), size: .large)
        }
      }
      .padding()
      .background(Color.ds.background.default)
    }.previewLayout(.sizeThatFits)
  }
}

extension Color {
  var personalSpace: Color {
    Color("personalSpace")
  }
}
