import SwiftUI

struct VWaterfallGrid<Content: View>: View {

    @ScaledMetric private var defaultSpacing = 8

    @State private var contentSize: CGSize = .zero
    @State private var transaction: Transaction = .init()

    private let alignment: Alignment
    private let spacing: CGFloat?

    private let content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: alignment) {
                Color.clear
                    .hidden()

                VWaterfallLayout(
                    alignment: alignment,
                    content: content,
                    size: geometry.size,
                    horizontalSpacing: spacing ?? defaultSpacing,
                    verticalSpacing: spacing ?? defaultSpacing
                )
                .transaction { updateTransaction($0) }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear { contentSize = geometry.size }
                            .onChange(of: geometry.size) { newValue in
                                DispatchQueue.main.async {
                                    withTransaction(transaction) { contentSize = newValue }
                                }
                            }
                    }
                    .hidden()
                )
            }
        }
        .frame(height: contentSize.height)
    }

    private func updateTransaction(_ newValue: Transaction) {
        if transaction.animation != newValue.animation
        || transaction.disablesAnimations != newValue.disablesAnimations
        || transaction.isContinuous != newValue.isContinuous {
            DispatchQueue.main.async {
                transaction = newValue
            }
        }
    }
}

extension VWaterfallGrid {
    init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = Alignment(horizontal: alignment, vertical: .top)
        self.spacing = spacing
        self.content = content
    }
}

struct VWaterfallGrid_Previews: PreviewProvider {
    static var previews: some View {
        VWaterfallGrid(alignment: .leading, spacing: 12) {
            ForEach(0...100, id: \.self) { i in
                Text("\(Int.random(in: 0...i) * Int.random(in: 0...i))")
            }
        }
        .padding(.horizontal, 10)
    }
}
