import CorePremium
import SwiftUI
import UIDelight

@MainActor
public protocol UserSpacePopoverModelProtocol: ObservableObject {
  var header: String? { get }
  var availableSpaces: [UserSpace] { get }
  var selectedSpace: UserSpace { get }
  var isPopoverPresented: Bool { get set }
  func select(_ space: UserSpace)
}

extension UserSpacePopoverModelProtocol {
  public var header: String? {
    return nil
  }
}

#if canImport(UIKit)

  struct UserSpacePopover<Model: UserSpacePopoverModelProtocol>: ViewModifier {

    @ObservedObject
    var model: Model

    @ViewBuilder
    func body(content: Content) -> some View {
      if model.availableSpaces.count < 2 {
        content
      } else {
        content
          .popover(
            isPresented: $model.isPopoverPresented,
            shouldDisplayPopoverOnSmallDevice: true,
            content: selectionView)
      }
    }

    func selectionView() -> some View {
      VStack(alignment: .leading, spacing: 0) {
        if model.header != nil {
          VStack(alignment: .leading, spacing: 12) {
            Text(model.header!.uppercased())
              .font(.body)
              .foregroundColor(.gray)
            Divider().opacity(0.5)
          }
          .padding(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16))
        }
        ForEach(self.model.availableSpaces) { userSpace in
          VStack(alignment: .leading, spacing: 12) {
            Button(
              action: {
                self.model.isPopoverPresented = false

                withAnimation(.default) {
                  self.model.select(userSpace)
                }
              },
              label: {
                HStack {
                  UserSpaceIcon(space: userSpace, size: .normal)
                  Text(userSpace.teamName)
                    .lineLimit(1)
                    .fixedSize()
                  Spacer()
                  if self.model.selectedSpace == userSpace {
                    Image(systemName: "checkmark").font(.body)
                  }
                }
              }
            )
            .buttonStyle(BorderlessButtonStyle())
            .foregroundColor(.ds.text.neutral.catchy)

            if self.model.availableSpaces.last != userSpace {
              Divider().opacity(0.5)
            }
          }
          .padding(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16))
        }
      }
      .padding(.bottom, 12)
      .frame(minWidth: 300)
    }
  }
#endif
