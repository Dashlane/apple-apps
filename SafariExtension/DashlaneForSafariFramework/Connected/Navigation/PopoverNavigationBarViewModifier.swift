import SwiftUI

struct PopoverNavigationBarViewModifier: ViewModifier {
    
    let style: PopoverNavigationBarStyle

    @Environment(\.popoverNavigator)
    var navigator
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            navigationBar
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
    }
    
    @ViewBuilder
    var navigationBar: some View {
        switch style {
        case let .default(navigation):
            defaultView(navigation: navigation)
                .frame(height: 80)
        case let .details(navigation):
            detailsView(navigation: navigation)
                .frame(height: 120)
        }
    }
    
    @ViewBuilder
    func defaultView(navigation: DefaultNavigation) -> some View {
        HStack {
                Button(action: {
                    navigation.leadingAction.action()
                    navigator?.popLast()
                }, label: {
                    navigation.leadingAction.image.swiftUIImage
                })
                .frame(width: 32, height: 32)
            Text(navigation.title)
                .font(Typography.title)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if let trailing = navigation.trailingAction {
                Button(action: trailing.action, label: {
                    trailing.image.swiftUIImage
                })
                .frame(width: 32, height: 32)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(Color(asset: Asset.dashGreenCopy))
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    func detailsView(navigation: DetailsNavigation) -> some View {
        VStack {
            HStack {
                Button(action: {
                    navigation.leadingAction.action()
                    assert(navigator != nil)
                    navigator?.popLast()
                }, label: {
                    navigation.leadingAction.image.swiftUIImage
                })
                .frame(width: 32, height: 32)
                Spacer()
                navigation.thumbnail
                Spacer()
                if let trailing = navigation.trailingAction {
                    Button(action: trailing.action, label: {
                        trailing.image.swiftUIImage
                    })
                    .frame(width: 32, height: 32)
                }
            }
            navigation.title
                .accessibilityAddTraits(.isHeader)
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(navigation.tintColor)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(navigation.backgroundColor.opacity(0.5))
    }
    
}

extension View {
    func navigationBar(style: PopoverNavigationBarStyle) -> some View {
        self.modifier(PopoverNavigationBarViewModifier(style: style))
    }
}
 
