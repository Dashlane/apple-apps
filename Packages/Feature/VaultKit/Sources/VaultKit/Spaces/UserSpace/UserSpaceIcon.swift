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
        .foregroundStyle(Color.ds.text.brand.standard)

    case .personal:
      UserSpaceLetterIcon(
        color: .ds.text.brand.quiet,
        title: CoreL10n.teamSpacesPersonalSpaceInitial,
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
          .foregroundStyle(color)
      } else {
        size.backgroundImage
          .foregroundStyle(color)

        if colorScheme == .dark {
          size.outlineImage
            .foregroundStyle(Color(white: 1, opacity: 0.7))
        }
      }

      Text(title)
        .font(.system(size: size.fontSize, weight: .bold, design: .monospaced))
        .foregroundStyle(size == .small ? color : .white)
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
    Image.ds.spaces.all.outlined
  }

  var backgroundImage: Image {
    switch self {
    case .small:
      return Image(.teamSpaceSmall)
    case .normal:
      return Image(.teamSpace)
    case .large:
      return Image(.teamSpaceLarge)
    }
  }

  var outlineImage: Image {
    switch self {
    case .small:
      return Image(.teamSpaceOutlineSmall)
    case .normal:
      return Image(.teamSpaceOutline)
    case .large:
      return Image(.teamSpaceOutlineLarge)
    }
  }
}

#Preview("Both Spaces", traits: .sizeThatFitsLayout) {
  HStack {
    UserSpaceIcon(space: .both, size: .small)
    UserSpaceIcon(space: .both, size: .normal)
    UserSpaceIcon(space: .both, size: .large)
  }
  .padding()
  .background(Color.ds.background.default)
}

#Preview("Personal Space", traits: .sizeThatFitsLayout) {
  HStack {
    UserSpaceIcon(space: .personal, size: .small)
    UserSpaceIcon(space: .personal, size: .normal)
    UserSpaceIcon(space: .personal, size: .large)
  }
  .padding()
  .background(Color.ds.background.default)
}

#Preview("Team Space", traits: .sizeThatFitsLayout) {
  HStack {
    UserSpaceIcon(space: .team(.mock()), size: .small)
    UserSpaceIcon(space: .team(.mock()), size: .normal)
    UserSpaceIcon(space: .team(.mock()), size: .large)
  }
  .padding()
  .background(Color.ds.background.default)
}

extension Color {
  var personalSpace: Color {
    Color("personalSpace")
  }
}
