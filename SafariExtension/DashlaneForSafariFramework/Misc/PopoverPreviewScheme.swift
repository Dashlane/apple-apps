import SwiftUI

struct PopoverPreviewScheme<Content: View>: View {

    enum Size {
                case popover
                case popoverContent
                case custom(_ width: CGFloat, _ height: CGFloat)
                case undefined
        
        var size: CGSize? {
            switch self {
            case .popover:
                return CGSize(width: 408, height: 560)
            case .popoverContent:
                return CGSize(width: 408, height: 480)
            case let .custom(width, height):
                return CGSize(width: width, height: height)
            case .undefined:
                return nil
            }
        }
    }

    private let contentSize: Size
    private let content: Content

    init(size: Size = .undefined, @ViewBuilder content: () -> Content) {
        self.contentSize = size
        self.content = content()
    }

    var body: some View {
        Group {
            self.contentPresentation(colorScheme: .light)
            self.contentPresentation(colorScheme: .dark).background(Color.black)
        }
    }

    @ViewBuilder
    private func contentPresentation(colorScheme: ColorScheme) -> some View {
        if let size = contentSize.size {
            self.content
                .frame(width: size.width, height: size.height)
                .environment(\.colorScheme, colorScheme)
        } else {
            self.content
                .environment(\.colorScheme, colorScheme)
        }
    }
}

private extension ColorScheme {
    var name: String {
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
