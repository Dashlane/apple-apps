import SwiftUI

public struct RoundedButtonTitleContentView: View {
    let label: Text

    public var body: some View {
        Label {
            label
        } icon: {
            EmptyView()
        }
        .labelStyle(RoundedButtonTitleOnlyLabelStyle())
        .accessibilityElement()
        .accessibilityLabel(label)
    }
}

public struct RoundedButtonIconContentView: View {
    let icon: Image

    public var body: some View {
        Label {
            EmptyView()
        } icon: {
            icon
                .resizable()
                .renderingMode(.template)
                .accessibilityHidden(true)
        }
        .labelStyle(RoundedButtonIconOnlyLabelStyle())
        .accessibilityElement(children: .combine)
    }
}

public struct RoundedButtonTitleIconContentView: View {
    let label: Text
    let icon: Image

    public var body: some View {
        Label {
            label
        } icon: {
            icon
                .resizable()
                .renderingMode(.template)
                .accessibilityHidden(true)
        }
        .labelStyle(RoundedButtonTitleAndIconLabelStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
    }
}
