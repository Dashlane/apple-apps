import CoreFeature
import DashTypes
import DesignSystem
import SwiftUI
import UIDelight
import UIKit

struct AlternateIconSwitcherView: View {
  @StateObject
  private var model: AlternateIconSwitcherViewModel

  @Environment(\.dismiss)
  var dismiss

  private var columns: [GridItem] = Array(
    repeating: .init(.flexible(), spacing: 24),
    count: 3)

  public init(model: @autoclosure @escaping () -> AlternateIconSwitcherViewModel) {
    _model = .init(wrappedValue: model())
  }

  var body: some View {
    NavigationView {
      list
    }
    .presentationDetents(model.showLegacyIcons ? [.large, .fraction(0.7)] : [.medium])
    .presentationDragIndicator(.visible)
    .animation(.spring(duration: 0.6, bounce: 0.7), value: model.showLegacyIcons)
  }

  var list: some View {
    LazyVGrid(columns: columns, spacing: 20) {
      ForEach(model.icons) { icon in
        row(for: icon)
      }
    }
    .padding(.horizontal, 28)
    .padding(.top, 10)
    .frame(maxHeight: .infinity, alignment: .top)
    .navigationTitle(L10n.Localizable.alternateIconSettingsTitle)
    .navigationBarTitleDisplayMode(.inline)
    .backgroundColorIgnoringSafeArea(.ds.background.default)
    .animation(.spring(dampingFraction: 0.8), value: model.currentIcon)
    .onReceive(model.successPublisher) { _ in
      dismiss()
    }
    .onShake {
      model.showLegacyIcons = true
    }
  }

  @ViewBuilder
  func row(for icon: AppIcon) -> some View {
    let isSelected = model.currentIcon == icon
    Button {
      self.model.changeIcon(to: icon)
    } label: {
      Image(uiImage: UIImage(named: icon.name)!)
        .resizable()
        .renderingMode(.original)
        .frame(width: 64, height: 64)
        .clipShape(ContainerRelativeShape())
        .overlay(
          ContainerRelativeShape()
            .stroke(Color.ds.border.neutral.standard.idle, lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
        .padding(4)
        .overlay {
          ContainerRelativeShape()
            .stroke(Color.ds.border.neutral.standard.idle, lineWidth: isSelected ? 2 : 0)
        }
        .containerShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
        .padding(4)
        .overlay(alignment: .bottomTrailing) {
          if isSelected {
            selectedIcon
              .transition(
                .asymmetric(
                  insertion: .scale(scale: 1.3),
                  removal: .scale.combined(with: .opacity))
              )
          }
        }
    }
    .buttonStyle(.plain)
    .transition(.scale(scale: 0.7).combined(with: .opacity))
  }

  var selectedIcon: some View {
    Circle()
      .foregroundColor(Color.ds.container.expressive.positive.catchy.active)
      .frame(width: 24, height: 24, alignment: .center)
      .overlay {
        Image.ds.checkmark.outlined
          .renderingMode(.template)
          .resizable()
          .foregroundColor(.ds.text.inverse.catchy)
          .padding(4)
      }

  }
}

struct AlternateIconSwitcherView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      AlternateIconSwitcherView(model: .init(showPrideIcon: true))
    }
  }
}
