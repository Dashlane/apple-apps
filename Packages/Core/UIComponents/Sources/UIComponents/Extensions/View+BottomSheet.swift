#if os(iOS)

import SwiftUI
import UIDelight
import DesignSystem

public extension View {
    @ViewBuilder
    func bottomSheet<Content: View>(isPresented: Binding<Bool>,
                                    detents: [BottomSheetDetents] = [.medium],
                                    @ViewBuilder content: @escaping () -> Content) -> some View {
        if #available(iOS 16.0, *) {
                        self
                .sheet(isPresented: isPresented,
                       content: {
                    content()
                        .presentationDetents(detents.detents)
                })
        } else {
            customBottomSheet(isPresented: isPresented, content: content)
        }
    }

    @ViewBuilder
    func customBottomSheet<Content: View>(isPresented: Binding<Bool>,
                                          @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .overlay(DimmingOverlay(isPresented: isPresented).edgesIgnoringSafeArea(.all))
            .overlay(BottomSheetView(isPresented: isPresented, content: content), alignment: .bottom)
            .animation(.spring(response: 0.55, dampingFraction: 0.6, blendDuration: 0), value: isPresented.wrappedValue)
    }

    @ViewBuilder
    func bottomSheet<Content: View, Item: Identifiable>(item: Binding<Item?>,
                                                        detents: [BottomSheetDetents] = [.medium],
                                                        @ViewBuilder content: @escaping (Item) -> Content) -> some View {
        if #available(iOS 16.0, *) {
            self
                .sheet(item: item,
                       content: { item in
                    content(item)
                        .presentationDetents(detents.detents)
                })
        } else {
            ZStack {
                if let item = item.wrappedValue {
                    self
                        .overlay(DimmingOverlay(isPresented: .constant(true)).edgesIgnoringSafeArea(.all))
                        .overlay(BottomSheetView(isPresented: .constant(true), content: { content(item) }), alignment: .bottom)
                } else {
                    self

                }
            }
            .animation(.spring(response: 0.55, dampingFraction: 0.6, blendDuration: 0), value: false)
        }
    }

    @ViewBuilder
    func bottomSheetBackground(_ color: Color) -> some View {
        if #available(iOS 16.0, *) {
            self
                .backgroundColorIgnoringSafeArea(color)
        } else {
            self
                .background(color)
        }
    }
}

private struct BottomSheetView<Content: View>: View {
    let content: Content
    @Binding var isPresented: Bool
    @GestureState private var translation: CGFloat = 0

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._isPresented = isPresented
    }

    var body: some View {
        VStack {
            if isPresented {
                Spacer()

                self.content
                    .cornerRadius(16, corners: [.topRight, .topLeft])
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .background(Color.ds.background.default
                                    .frame(height: 200)
                                    .edgesIgnoringSafeArea(.all)
                                    .alignmentGuide(.bottom, to: .top),
                                alignment: .bottom)
                    .offset(y: max(self.translation, -50))
                    .gesture(
                        DragGesture().updating(self.$translation) { value, state, _ in
                            state = value.translation.height
                        }.onEnded { value in
                            if value.translation.height > 80 {
                                self.isPresented = false
                            }
                        }
                    )
            }
        }
        .animation(.spring(dampingFraction: 0.6), value: translation)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}

private struct DimmingOverlay: View {
    @Binding var isPresented: Bool

    var body: some View {
        if isPresented {
            Color
                .black
                .opacity(0.3)
                .onTapGesture { self.isPresented = false }
                .transition(.opacity)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct BottomSheetView_Previews: PreviewProvider {
    struct DemoView: View {
        @State
        var isPresented: Bool = false

        var body: some View {
            Button("Toggle Bottom Sheet") {
                isPresented = true
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .bottomSheet(isPresented: $isPresented) {
                Text("Thiis ia a bottom sheet")
            }
        }
    }

    static var previews: some View {
        MultiContextPreview {
            DemoView()
        }

    }
}
#endif
