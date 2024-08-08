import Foundation

extension SceneType {
  func instantiante(creator: @escaping ((NSCoder) -> T?)) -> T {
    return storyboard.storyboard.instantiateViewController(identifier: identifier, creator: creator)
  }
}
