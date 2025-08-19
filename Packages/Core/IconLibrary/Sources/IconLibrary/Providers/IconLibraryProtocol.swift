import Foundation

public protocol IconServiceProtocol {
  var domain: DomainIconLibraryProtocol { get }
  var gravatar: GravatarIconLibraryProtocol { get }
}

public class IconServiceMock: IconServiceProtocol {
  public var domain: DomainIconLibraryProtocol = FakeDomainIconLibrary(icon: nil)
  public var gravatar: GravatarIconLibraryProtocol = FakeGravatarIconLibrary(icon: nil)

  public init() {}
}

extension IconServiceProtocol where Self == IconServiceMock {
  public static func mock() -> IconServiceMock {
    IconServiceMock()
  }
}
