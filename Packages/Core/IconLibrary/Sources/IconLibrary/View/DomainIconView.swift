import SwiftUI
import DashTypes
import DesignSystem

public struct DomainIconView: View {

    let animate: Bool
    let model: DomainIconViewModel
    let placeholderTitle: String

    public init(animate: Bool = true,
                model: DomainIconViewModel,
                placeholderTitle: String) {
        self.animate = animate
        self.model = model
        self.placeholderTitle = placeholderTitle
    }

    public var body: some View {
        AsyncIconView(animate: animate) {
            try await model.icon()
        } content: { image, colors in
            icon(for: image, colors: colors)
        } placeholder: {
            placeholder
        }
        .id(model.domain?.name ?? placeholderTitle)
    }

    @ViewBuilder
    private var placeholder: some View {
        let style = IconStyle(backgroundColor: .ds.container.agnostic.neutral.standard, sizeType: model.size)
        PlaceholderIconView(title: placeholderTitle, sizeType: model.size)
            .overlay(style.shape.inset(by: 0.5).stroke(SwiftUI.Color.ds.border.neutral.quiet.idle, lineWidth: 1.61))
    }

    @ViewBuilder
    private func icon(for image: SwiftUI.Image, colors: IconColorSet?) -> some View {
        let colorSet = colors ?? .placeholderColorSet
        let style = IconStyle(backgroundColor: SwiftUI.Color(colorSet.backgroundColor), sizeType: model.size)
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .modifier(style)
            .overlay(style.shape.inset(by: 0.5).stroke(borderColor(for: colorSet), lineWidth: 1))
    }

    private func borderColor(for colorSet: IconColorSet) -> SwiftUI.Color {
        if colorSet.backgroundColor.isBorderRequired() {
            return .ds.border.neutral.quiet.idle
        } else {
            return SwiftUI.Color(colorSet.backgroundColor)
        }
    }
}

extension IconColorSet {
    static var placeholderColorSet: IconColorSet {
        IconColorSet(
            backgroundColor: .ds.container.agnostic.neutral.standard,
            mainColor: .ds.container.agnostic.neutral.standard,
            fallbackColor: .ds.container.agnostic.neutral.standard
        )
    }
}

public struct DomainIconViewModel {
    let domain: Domain?
    let size: IconStyle.SizeType
    let iconLibrary: DomainIconLibraryProtocol

    public init(domain: Domain?, size: IconStyle.SizeType, iconLibrary: DomainIconLibraryProtocol) {
        self.domain = domain
        self.size = size
        self.iconLibrary = iconLibrary
    }

    func icon() async throws -> Icon? {
        guard let domain = domain else {
            return nil
        }

        return try await iconLibrary.icon(for: domain, format: .iOS(large: size == .large || size == .prefilledCredential))
    }
}

extension DomainIconViewModel {
    public static func makeMock(domain: Domain?, size: IconStyle.SizeType) -> DomainIconViewModel {
        DomainIconViewModel(domain: domain, size: size, iconLibrary: FakeDomainIconLibrary(icon: nil))
    }
}

struct DomainIconView_Previews: PreviewProvider {
    static let placeholder = Text("placeholder")
    static var previews: some View {
        Group {
            let smallIconModel = DomainIconViewModel(domain: Domain(name: "random", publicSuffix: ".org"),
                                                     size: .small,
                                                     iconLibrary: FakeDomainIconLibrary(icon: Icon(image: Asset.logomark.image)))
            DomainIconView(model: smallIconModel,
                           placeholderTitle: "as")
                .previewDisplayName("Small")

            let largeIconModel = DomainIconViewModel(domain: Domain(name: "random", publicSuffix: ".org"),
                                                     size: .small,
                                                     iconLibrary: FakeDomainIconLibrary(icon: Icon(image: Asset.logomark.image)))
            DomainIconView(model: largeIconModel,
                           placeholderTitle: "as")
                .previewDisplayName("Large")

            let colors = IconColorSet(backgroundColor: .red, mainColor: .red, fallbackColor: .red)

            let modelWithColors = DomainIconViewModel(domain: Domain(name: "random", publicSuffix: ".org"),
                                                      size: .small,
                                                      iconLibrary: FakeDomainIconLibrary(icon: Icon(image: Asset.logomark.image, colors: colors)))
            DomainIconView(model: modelWithColors,
                           placeholderTitle: "as")
                .previewDisplayName("Background Colors")

            let modelWithoutIcon = DomainIconViewModel(domain: Domain(name: "random", publicSuffix: ".org"),
                                                      size: .small,
                                                      iconLibrary: FakeDomainIconLibrary(icon: nil))
            DomainIconView(model: modelWithoutIcon,
                           placeholderTitle: "as")
                .previewDisplayName("Placeholder")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
