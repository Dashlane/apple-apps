#if canImport(UIKit)
import SwiftUI
import UIKit
import AVKit

public struct PlayerView: UIViewRepresentable {
    let player: AVPlayer

    public init(player: AVPlayer) {
        self.player = player
    }

    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }

    public func makeUIView(context: Context) -> UIView {
        return PlayerUIView(player: player)
    }
}

private class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()

    init(player: AVPlayer) {
        super.init(frame: .zero)
        playerLayer.player = player
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

}
#endif
