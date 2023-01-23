import Foundation
import SwiftUI
import UIDelight

struct AdaptiveContainer: ViewModifier {

    @State
    var enableScroll: Bool = false

    @State
    var contentHeight: CGFloat?

    let scrollViewStatusUpdated: ((Bool) -> Void)?

    func body(content: Content) -> some View {
        GeometryReader { containerGeo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    content
                        .overlay(GeometryReader { contentGeo in
                            Rectangle()
                                .foregroundColor(.clear)
                                .preference(key: HeightValuesPreferenceKey.self, value: HeightValues(contentHeight: contentGeo.size.height, containerHeight: containerGeo.size.height))
                                .onPreferenceChange(HeightValuesPreferenceKey.self, perform: { heightValues in
                                    if self.contentHeight == nil {
                                        self.contentHeight = heightValues.contentHeight
                                    }

                                    if enableScroll == true {
                                        if heightValues.contentHeight > heightValues.containerHeight {
                                            enableScroll = true
                                            scrollViewStatusUpdated?(true)
                                        } else {
                                            enableScroll = false
                                            scrollViewStatusUpdated?(false)
                                        }
                                    } else {
                                        if self.contentHeight != heightValues.contentHeight {
                                                                                        enableScroll = true
                                        }
                                    }

                                    self.contentHeight = heightValues.contentHeight
                                })
                        })
                }
                .frame(minHeight: containerGeo.size.height)
            }
            .enableScroll(enableScroll)
        }
    }
}

extension View {
    func embedInScrollViewIfNeeded(scrollViewStatusUpdated: ((Bool) -> Void)? = nil) -> some View {
        return self.modifier(AdaptiveContainer(scrollViewStatusUpdated: scrollViewStatusUpdated))
    }
}

private struct HeightValues: Equatable {
    let contentHeight: CGFloat
    let containerHeight: CGFloat
}

private struct HeightValuesPreferenceKey: PreferenceKey {
    static var defaultValue: HeightValues = HeightValues(contentHeight: 0, containerHeight: 0)

    static func reduce(value: inout HeightValues, nextValue: () -> HeightValues) {
        value = nextValue()
    }
}

struct ConditionalScrollView_Previews: PreviewProvider {

    private struct TestView: View {

        @State
        var showDetails: Bool = true

        var body: some View {
            VStack {
                VStack(spacing: 0) {
                    Button(action: { showDetails.toggle() }, title: "Show details")

                    if showDetails {
                                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec rutrum, massa vel tempor ultricies, ex metus elementum eros, at commodo quam dolor eu urna. Sed sollicitudin fringilla blandit. Phasellus tempor, lorem sit amet vestibulum laoreet, magna magna accumsan urna, in dapibus felis mi quis magna. Nam vel tempor tortor. In hac habitasse platea dictumst. Nunc dictum, urna ut imperdiet posuere, magna tellus fringilla nulla, nec porta nisl nibh vel odio. Nulla facilisi. Cras id augue leo.")
                    } else {
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    }
                }.embedInScrollViewIfNeeded()
            }.frame(height: 150)
        }
    }

    static var previews: some View {
        TestView().previewLayout(.sizeThatFits)
    }
}
