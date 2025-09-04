import CoreLocalization
import CorePremium
import DesignSystem
import Foundation
import SwiftUI
import UIKit

public struct UserSpaceSwitcher<Accessory: View>: View {
  @StateObject
  var model: UserSpaceSwitcherViewModel

  @State
  var isPopoverPresented: Bool = false

  let accessory: Accessory

  private let displayTeamName: Bool

  public init(
    model: @autoclosure @escaping () -> UserSpaceSwitcherViewModel,
    @ViewBuilder accessory: () -> Accessory
  ) {
    self._model = .init(wrappedValue: model())
    self.accessory = accessory()
    self.displayTeamName = false
  }

  @ViewBuilder
  public var body: some View {
    if model.availableSpaces.count < 2 {
      accessory
    } else {
      Button(
        action: {
          self.model.isPopoverPresented = true
        },
        label: {
          if self.displayTeamName {
            self.buttonWithTeamName
          } else {
            self.buttonWithAccessory
          }
        }
      )
      .accessibility(label: Text(CoreL10n.dashlaneBusinessActiveSpacesTitle))
    }
  }

  @ViewBuilder
  var buttonWithTeamName: some View {
    HStack(spacing: 0) {
      UserSpaceIcon(space: model.selectedSpace, size: .normal)
        .equatable()
        .padding(4)
        .modifier(UserSpacePopover(model: model))
      Text(model.selectedSpace.teamName)
        .foregroundStyle(Color.ds.text.brand.standard)
        .font(.subheadline.weight(.regular))
    }
  }

  @ViewBuilder
  var buttonWithAccessory: some View {
    HStack(spacing: 4) {
      accessory
      UserSpaceIcon(space: model.selectedSpace, size: .normal)
        .equatable()
        .padding(4)
        .modifier(UserSpacePopover(model: model))
    }
  }
}

extension UserSpaceSwitcher where Accessory == EmptyView {
  public init(model: @autoclosure @escaping () -> UserSpaceSwitcherViewModel) {
    self.init(model: model(), accessory: { EmptyView() })
  }

  public init(model: @autoclosure @escaping () -> UserSpaceSwitcherViewModel, displayTeamName: Bool)
  {
    self._model = .init(wrappedValue: model())
    self.displayTeamName = displayTeamName
    self.accessory = EmptyView()
  }
}

struct UserSpaceSwitcher_Previews: PreviewProvider {
  static let model = UserSpaceSwitcherViewModel(
    userSpacesService: .mock(status: .Mock.team), activityReporter: .mock)

  static var previews: some View {
    Group {
      NavigationView {
        Text("Content")
          .toolbar {
            ToolbarItem(placement: .principal) {
              UserSpaceSwitcher(model: model) {
                Text("Title")
                  .foregroundStyle(.primary)
                  .font(.headline)
                  .lineLimit(1)
                  .fixedSize(horizontal: true, vertical: false)
              }
            }
          }
      }
      UserSpaceSwitcher(model: model, displayTeamName: true)
        .previewLayout(.sizeThatFits)
    }
  }
}
