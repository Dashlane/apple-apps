import SwiftUI

struct TextFieldActionContainer<Content: View>: View {
    @Environment(\.tintColor) private var tintColor

    @ScaledMetric private var imageDimension = 20
    private let minimumTapAreaDimension: CGFloat = 40

    private let actionContent: Content

    init(@ViewBuilder content: () -> Content) {
        actionContent = content()
    }

    var body: some View {
        actionContent
            .labelStyle(.iconOnly)
            .frame(width: imageDimension, height: imageDimension)
            .frame(minWidth: minimumTapAreaDimension, minHeight: minimumTapAreaDimension)
            .contentShape(Rectangle())
            .foregroundColor(tintColor ?? .accentColor)
    }
}

struct TextFieldActionContainer_Previews: PreviewProvider {
    struct Preview: View {
        @State private var revealSecureContent = false

        var body: some View {
            HStack {
                TextFieldActionContainer {
                    TextFieldButtonAction(
                        "Password Generator",
                        image: .ds.feature.passwordGenerator.outlined,
                        action: {}
                    )
                }

                TextFieldActionContainer {
                    TextFieldAction.RevealSecureContent(reveal: $revealSecureContent)
                }

                TextFieldActionContainer {
                    TextFieldAction.Button(
                        "Copy",
                        image: .ds.action.copy.outlined,
                        action: {}
                    )
                }

                TextFieldActionContainer {
                    TextFieldAction.Menu("More", image: .ds.action.more.outlined) {
                        Button(
                            action: {},
                            label: {
                                Label {
                                    Text("Copy Credential")
                                } icon: {
                                    Image.ds.action.copy.outlined
                                        .resizable()
                                }
                            }
                        )
                        Button(
                            action: {},
                            label: {
                                Label {
                                    Text("Open Website")
                                } icon: {
                                    Image.ds.action.openExternalLink.outlined
                                        .resizable()
                                }
                            }
                        )
                    }
                }
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}
