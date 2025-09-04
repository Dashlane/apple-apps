import Foundation

extension Definition {

  public struct `Browse`: Encodable, Sendable {
    public init(
      `component`: Definition.BrowseComponent? = nil,
      `originComponent`: Definition.BrowseComponent? = nil,
      `originPage`: Page? = nil, `page`: Page? = nil
    ) {
      self.component = component
      self.originComponent = originComponent
      self.originPage = originPage
      self.page = page
    }
    public let component: Definition.BrowseComponent?
    public let originComponent: Definition.BrowseComponent?
    public let originPage: Page?
    public let page: Page?
  }
}
