import Foundation

struct FAQItem: Hashable {

  struct Description: Hashable {

    struct Link: Hashable {
      let label: String
      let url: URL
    }

    let title: String
    let link: Link?

    init(title: String, link: Link? = nil) {
      self.title = title
      self.link = link
    }
  }

  let title: String
  let descriptions: [Description]

  init(title: String, description: FAQItem.Description, link: FAQItem.Description.Link? = nil) {
    self.title = title
    self.descriptions = [description]
  }

  init(title: String, description: String, link: FAQItem.Description.Link? = nil) {
    self.title = title
    self.descriptions = [.init(title: description, link: link)]
  }

  init(title: String, descriptions: [FAQItem.Description]) {
    self.title = title
    self.descriptions = descriptions
  }
}
