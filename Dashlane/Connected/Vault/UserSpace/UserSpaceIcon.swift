import SwiftUI
import CorePremium
import UIDelight
import DashlaneAppKit
import DesignSystem

struct UserSpaceIcon: View, Equatable {
    enum Size: Equatable {
        case small
        case normal
        case large
    }

    let space: UserSpace
    let size: Size

    var body: some View {
        switch space {
        case .both:
            size
                .allSpaceImage
                .foregroundColor(.ds.text.brand.standard)

        case .personal:
            UserSpaceLetterIcon(
                color: Color(asset: SharedAsset.personalSpaceIconColor),
                title: L10n.Localizable.teamSpacesPersonalSpaceInitial,
                size: size
            )

        case let .business(team):
            let color = Color(hex: team.space.color) ?? Color.ds.text.brand.standard
            UserSpaceLetterIcon(
                color: color,
                title: team.space.letter,
                size: size
            )
        }
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
        Image(asset: SharedAsset.allSpaces)
    }

    var backgroundImage: Image {
        switch self {
            case .small:
                return Image(asset: SharedAsset.teamSpaceSmall)
            case .normal:
                return Image(asset: SharedAsset.teamSpace)
            case .large:
                return Image(asset: SharedAsset.teamSpaceLarge)
        }
    }

    var outlineImage: Image {
        switch self {
            case .small:
                return Image(asset: SharedAsset.teamSpaceOutlineSmall)
            case .normal:
                return Image(asset: SharedAsset.teamSpaceOutline)
            case .large:
                return Image(asset: SharedAsset.teamSpaceOutlineLarge)
        }
    }
}

struct TeamSpaceView_Previews: PreviewProvider {

    static let businessSpace = Space(teamId: "id",
                                      teamName: "Jason&Jeremy SAS",
                                      letter: "J",
                                      color: "d22",
                                      associatedEmail: "",
                                      membersNumber: 1,
                                      teamAdmins: [],
                                      billingAdmins: [],
                                      isTeamAdmin: true,
                                      isBillingAdmin: true,
                                      planType: "",
                                      status: .accepted,
                                      info: SpaceInfo())

    static var userTeamSpace = UserSpace.business(.init(space: TeamSpaceView_Previews.businessSpace,
                                                        anonymousTeamId: ""))
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
                    UserSpaceIcon(space: userTeamSpace, size: .small)
                    UserSpaceIcon(space: userTeamSpace, size: .normal)
                    UserSpaceIcon(space: userTeamSpace, size: .large)
                }
            }
            .padding()
            .background(Color.ds.background.default)
        }.previewLayout(.sizeThatFits)
    }
}
