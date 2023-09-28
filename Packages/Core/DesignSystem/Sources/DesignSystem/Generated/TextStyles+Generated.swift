import Foundation
import SwiftUI

#if canImport(UIKit)
extension UIFont.TextStyle {
    init(_ textStyle: SwiftUI.Font.TextStyle) {
        switch textStyle {
        case .largeTitle:
            self = .largeTitle
        case .title:
            self = .title1
        case .title2:
            self = .title2
        case .title3:
            self = .title3
        case .headline:
            self = .headline
        case .subheadline:
            self = .subheadline
        case .body:
            self = .body
        case .callout:
            self = .callout
        case .footnote:
            self = .footnote
        case .caption:
            self = .caption1
        case .caption2:
            self = .caption2
        @unknown default:
            self = .body
        }
    }
}
#endif

extension SwiftUI.Font.TextStyle {
    func scaledValue(for value: CGFloat, compatibleWith dynamicTypeSize: DynamicTypeSize) -> CGFloat {
        #if canImport(UIKit)
        return UIFontMetrics(forTextStyle: .init(self)).scaledValue(
            for: value,
            compatibleWith: UITraitCollection(
                preferredContentSizeCategory: UIContentSizeCategory(dynamicTypeSize)
            )
        )
        #else
        return value
        #endif
    }
}

struct FontProvider {
    private let provider: (DynamicTypeSize) -> SwiftUI.Font
    init(provider: @escaping (DynamicTypeSize) -> SwiftUI.Font) {
        self.provider = provider
    }
    func callAsFunction(for dynamicTypeSize: DynamicTypeSize) -> SwiftUI.Font {
        provider(dynamicTypeSize)
    }
}

public struct TextStyle {
    let font: FontProvider
    fileprivate let tracking: CGFloat
    fileprivate let textCase: Text.Case?
    fileprivate let isUnderlined: Bool

    fileprivate init(font: FontProvider, tracking: CGFloat, isUppercased: Bool, isUnderlined: Bool) {
        self.font = font
        self.tracking = tracking
        self.textCase = isUppercased ? .uppercase : .none
        self.isUnderlined = isUnderlined
    }
}

struct TextStyleViewModifier: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let style: TextStyle

    func body(content: Content) -> some View {
        content.font(style.font(for: dynamicTypeSize))
            .tracking(style.tracking)
            .textCase(style.textCase)
            .underline(style.isUnderlined)
    }
}

extension View {
                    public func textStyle(_ style: TextStyle) -> some View {
        modifier(TextStyleViewModifier(style: style))
    }
}

extension TextStyle {
    public enum body {
        public enum helper {
            public static let regular = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.footnote.scaledValue(
                            for: 13,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .regular,
                        design: .default
                    )
                    .leading(.standard)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
        }
        public enum reduced {
            public static let monospace = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.subheadline.scaledValue(
                            for: 15,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .regular,
                        design: .monospaced
                    )
                    .leading(.standard)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
            public static let regular = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.subheadline.scaledValue(
                            for: 15,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .regular,
                        design: .default
                    )
                    .leading(.standard)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
            public static let strong = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.subheadline.scaledValue(
                            for: 15,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .semibold,
                        design: .default
                    )
                    .leading(.standard)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
        }
        public enum standard {
            public static let monospace = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.body.scaledValue(
                            for: 17,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .regular,
                        design: .monospaced
                    )
                    .leading(.standard)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
            public static let regular = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.body.scaledValue(
                            for: 17,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .regular,
                        design: .default
                    )
                    .leading(.standard)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
            public static let strong = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.body.scaledValue(
                            for: 17,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .semibold,
                        design: .default
                    )
                    .leading(.standard)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
        }
    }
    public enum component {
        public enum badge {
            public static let standard = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.caption.scaledValue(
                            for: 12,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .medium,
                        design: .default
                    )
                    .leading(.tight)
                },
                tracking: 0,
                isUppercased: true,
                isUnderlined: false
            )
        }
        public enum button {
            public static let small = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.subheadline.scaledValue(
                            for: 15,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .medium,
                        design: .default
                    )
                    .leading(.tight)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
            public static let standard = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.headline.scaledValue(
                            for: 17,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .medium,
                        design: .default
                    )
                    .leading(.tight)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
        }
    }
    public enum specialty {
        public enum brand {
            public static let large = TextStyle(
                font: FontProvider { _ in
                    FontFamily.GTWalsheimPro.medium.swiftUIFont(
                        size: 53,
                        relativeTo: .largeTitle
                    )
                    .leading(.tight)
                },
                tracking: -1.5899999999999999,
                isUppercased: false,
                isUnderlined: false
            )
            public static let medium = TextStyle(
                font: FontProvider { _ in
                    FontFamily.GTWalsheimPro.medium.swiftUIFont(
                        size: 40,
                        relativeTo: .largeTitle
                    )
                    .leading(.tight)
                },
                tracking: -0.8,
                isUppercased: false,
                isUnderlined: false
            )
            public static let small = TextStyle(
                font: FontProvider { _ in
                    FontFamily.GTWalsheimPro.medium.swiftUIFont(
                        size: 30,
                        relativeTo: .title
                    )
                    .leading(.tight)
                },
                tracking: -0.6,
                isUppercased: false,
                isUnderlined: false
            )
        }
        public enum monospace {
            public static let large = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.largeTitle.scaledValue(
                            for: 53,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .regular,
                        design: .monospaced
                    )
                    .leading(.tight)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
            public static let medium = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.largeTitle.scaledValue(
                            for: 35,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .regular,
                        design: .monospaced
                    )
                    .leading(.tight)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
            public static let small = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.title.scaledValue(
                            for: 26,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .regular,
                        design: .monospaced
                    )
                    .leading(.tight)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
        }
        public enum spotlight {
            public static let large = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.largeTitle.scaledValue(
                            for: 53,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .regular,
                        design: .default
                    )
                    .leading(.tight)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
            public static let medium = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.largeTitle.scaledValue(
                            for: 35,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .regular,
                        design: .default
                    )
                    .leading(.tight)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
            public static let small = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.title.scaledValue(
                            for: 26,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .regular,
                        design: .default
                    )
                    .leading(.tight)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
        }
    }
    public enum title {
        public enum block {
            public static let medium = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.headline.scaledValue(
                            for: 17,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .medium,
                        design: .default
                    )
                    .leading(.tight)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
            public static let small = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.subheadline.scaledValue(
                            for: 15,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .medium,
                        design: .default
                    )
                    .leading(.tight)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
        }
        public enum section {
            public static let large = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.title.scaledValue(
                            for: 30,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .medium,
                        design: .default
                    )
                    .leading(.tight)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
            public static let medium = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.title2.scaledValue(
                            for: 23,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .medium,
                        design: .default
                    )
                    .leading(.tight)
                },
                tracking: 0,
                isUppercased: false,
                isUnderlined: false
            )
        }
        public enum supporting {
            public static let small = TextStyle(
                font: FontProvider { dynamicTypeSize in
                    .system(
                        size: SwiftUI.Font.TextStyle.footnote.scaledValue(
                            for: 13,
                            compatibleWith: dynamicTypeSize
                        ),
                        weight: .medium,
                        design: .default
                    )
                    .leading(.tight)
                },
                tracking: 0,
                isUppercased: true,
                isUnderlined: false
            )
        }
    }
}
