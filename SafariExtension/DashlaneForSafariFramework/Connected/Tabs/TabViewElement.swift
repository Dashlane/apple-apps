import Foundation

protocol TabViewElement: Equatable {
    var title: String? { get }
    var image: ImageAsset { get }
    var distributedSizePercentage: CGFloat { get }
    var isActive: Bool { get }
}
